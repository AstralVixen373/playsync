import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll"
export default class extends Controller {
  static targets = ["messages"]
  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
  messagesTargetConnected() {
    console.log("coucou")
    this.scrollToBottom()
  }
  connect() {
    console.log("test")
  }
}
