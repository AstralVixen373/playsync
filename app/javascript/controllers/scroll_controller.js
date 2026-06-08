import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll"
export default class extends Controller {
  static targets = ["messages", "message"]
  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
  messageTargetConnected() {
    console.log("coucou")
    this.scrollToBottom()
  }
  connect() {
    console.log("test")
  }
}
