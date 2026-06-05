import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Mesh WebRTC voice room for a post (up to ~4 participants).
//
// Each browser connects directly to every other participant. Action Cable
// (VoiceChannel) is used only to exchange connection-setup messages; the
// audio itself flows peer-to-peer over WebRTC.
//
// Discovery / negotiation:
//   - On join, a peer broadcasts "join".
//   - Anyone already in the room answers with "present" (so the newcomer
//     learns about them) and both ensure a peer connection.
//   - To avoid glare, only the peer with the LOWER user id sends the offer;
//     the other side answers. ICE candidates are exchanged targeted.
const ICE_SERVERS = [{ urls: "stun:stun.l.google.com:19302" }]

export default class extends Controller {
  static values = { postId: Number, userId: Number }
  static targets = ["joinButton", "leaveButton", "muteButton", "status", "audios"]

  connect() {
    this.peers = new Map()      // remoteUserId -> RTCPeerConnection
    this.audioEls = new Map()   // remoteUserId -> <audio>
    this.localStream = null
    this.subscription = null
    this.joined = false
    this.muted = false
    this.updateButtons()
  }

  disconnect() {
    this.leave()
  }

  async join() {
    if (this.joined) return

    try {
      this.localStream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false })
    } catch (error) {
      this.setStatus("🎙️ Micro indisponible ou refusé.")
      return
    }

    this.joined = true
    this.subscription = this.createSubscription()
    this.updateButtons()
    this.setStatus("🔊 Connecté au vocal")
  }

  leave() {
    if (!this.joined && !this.subscription) return

    if (this.joined) this.signal({ type: "leave" })

    this.peers.forEach((peer) => peer.close())
    this.peers.clear()

    this.audioEls.forEach((el) => {
      el.srcObject = null
      el.remove()
    })
    this.audioEls.clear()

    if (this.localStream) {
      this.localStream.getTracks().forEach((track) => track.stop())
      this.localStream = null
    }

    if (this.subscription) {
      this.subscription.unsubscribe()
      this.subscription = null
    }

    this.joined = false
    this.muted = false
    this.updateButtons()
    this.setStatus("")
  }

  toggleMute() {
    if (!this.localStream) return

    this.muted = !this.muted
    this.localStream.getAudioTracks().forEach((track) => (track.enabled = !this.muted))

    if (this.hasMuteButtonTarget) {
      this.muteButtonTarget.textContent = this.muted ? "🔈 Activer le micro" : "🔇 Couper le micro"
    }
  }

  // --- Action Cable wiring -------------------------------------------------

  createSubscription() {
    const controller = this

    return consumer.subscriptions.create(
      { channel: "VoiceChannel", post_id: this.postIdValue },
      {
        connected() {
          controller.signal({ type: "join" })
        },
        received(data) {
          controller.handleSignal(data)
        }
      }
    )
  }

  signal(payload) {
    if (!this.subscription) return
    this.subscription.perform("signal", payload)
  }

  async handleSignal(data) {
    if (!this.joined) return

    const from = data.from_user_id
    if (from === this.userIdValue) return // ignore our own broadcast
    if (data.to_user_id && data.to_user_id !== this.userIdValue) return // not for us

    switch (data.type) {
      case "join":
        // A newcomer arrived: announce ourselves, then connect.
        this.signal({ type: "present", to_user_id: from })
        await this.connectTo(from)
        break
      case "present":
        await this.connectTo(from)
        break
      case "offer":
        await this.handleOffer(from, data.sdp)
        break
      case "answer":
        await this.handleAnswer(from, data.sdp)
        break
      case "ice":
        await this.handleIce(from, data.candidate)
        break
      case "leave":
        this.removePeer(from)
        break
    }
  }

  // --- WebRTC peer management ----------------------------------------------

  ensurePeer(remoteId) {
    let peer = this.peers.get(remoteId)
    if (peer) return peer

    peer = new RTCPeerConnection({ iceServers: ICE_SERVERS })

    this.localStream.getTracks().forEach((track) => peer.addTrack(track, this.localStream))

    peer.onicecandidate = (event) => {
      if (event.candidate) {
        this.signal({ type: "ice", to_user_id: remoteId, candidate: event.candidate })
      }
    }

    peer.ontrack = (event) => this.attachAudio(remoteId, event.streams[0])

    this.peers.set(remoteId, peer)
    return peer
  }

  // Only the lower user id initiates the offer, so each pair negotiates once.
  async connectTo(remoteId) {
    const peer = this.ensurePeer(remoteId)

    if (this.userIdValue < remoteId && !peer._offered && peer.signalingState === "stable") {
      peer._offered = true
      const offer = await peer.createOffer()
      await peer.setLocalDescription(offer)
      this.signal({ type: "offer", to_user_id: remoteId, sdp: peer.localDescription })
    }
  }

  async handleOffer(remoteId, sdp) {
    const peer = this.ensurePeer(remoteId)
    await peer.setRemoteDescription(new RTCSessionDescription(sdp))
    const answer = await peer.createAnswer()
    await peer.setLocalDescription(answer)
    this.signal({ type: "answer", to_user_id: remoteId, sdp: peer.localDescription })
  }

  async handleAnswer(remoteId, sdp) {
    const peer = this.peers.get(remoteId)
    if (peer) await peer.setRemoteDescription(new RTCSessionDescription(sdp))
  }

  async handleIce(remoteId, candidate) {
    const peer = this.peers.get(remoteId)
    if (!peer || !candidate) return
    try {
      await peer.addIceCandidate(new RTCIceCandidate(candidate))
    } catch (error) {
      // Candidate may arrive before the remote description; safe to ignore.
    }
  }

  attachAudio(remoteId, stream) {
    let el = this.audioEls.get(remoteId)
    if (!el) {
      el = document.createElement("audio")
      el.autoplay = true
      el.playsInline = true
      el.dataset.remoteId = remoteId
      ;(this.hasAudiosTarget ? this.audiosTarget : this.element).appendChild(el)
      this.audioEls.set(remoteId, el)
    }
    el.srcObject = stream
  }

  removePeer(remoteId) {
    const peer = this.peers.get(remoteId)
    if (peer) {
      peer.close()
      this.peers.delete(remoteId)
    }

    const el = this.audioEls.get(remoteId)
    if (el) {
      el.srcObject = null
      el.remove()
      this.audioEls.delete(remoteId)
    }
  }

  // --- UI helpers ----------------------------------------------------------

  updateButtons() {
    if (this.hasJoinButtonTarget) this.joinButtonTarget.style.display = this.joined ? "none" : ""
    if (this.hasLeaveButtonTarget) this.leaveButtonTarget.style.display = this.joined ? "" : "none"
    if (this.hasMuteButtonTarget) this.muteButtonTarget.style.display = this.joined ? "" : "none"
  }

  setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }
}
