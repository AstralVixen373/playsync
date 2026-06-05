# Real-time signaling channel for the voice room attached to a post.
#
# It does NOT carry audio: WebRTC streams audio peer-to-peer between browsers.
# This channel only relays connection-setup messages (join/present/offer/
# answer/ice/leave) between members of the same post chat.
#
# Authorization mirrors the rest of the app: only users who joined the post
# (Post#member? -> they have a UserChat, the creator included) may subscribe.
class VoiceChannel < ApplicationCable::Channel
  def subscribed
    post = authorized_post
    return reject unless post

    stream_from stream_name(post)
  end

  # Relay a WebRTC signaling message to the other members of the room.
  # The sender id is stamped server-side so it cannot be spoofed; clients
  # ignore their own messages and only act on those addressed to them.
  def signal(data)
    post = authorized_post
    return unless post

    payload = data.slice("type", "to_user_id", "sdp", "candidate")
    payload["from_user_id"] = current_user.id

    ActionCable.server.broadcast(stream_name(post), payload)
  end

  private

  def authorized_post
    post = Post.find_by(id: params[:post_id])
    post if post&.member?(current_user)
  end

  def stream_name(post)
    "voice_post_#{post.id}"
  end
end
