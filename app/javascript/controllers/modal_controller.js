import { Controller } from "@hotwired/stimulus"

// Opens the "Create announcement" form as an overlay above the posts board.
// The trigger keeps a real href (/posts/new) so it still works without JS;
// here we intercept the click, reveal the overlay and blur/lock the page behind.
export default class extends Controller {
  static targets = ["overlay"]

  open(event) {
    if (!this.hasOverlayTarget) return
    event.preventDefault()

    this.overlayTarget.hidden = false
    // Next frame so the transition runs from the hidden state.
    requestAnimationFrame(() => this.overlayTarget.classList.add("is-open"))
    document.body.classList.add("ps-modal-open")

    const field = this.overlayTarget.querySelector("input, select, textarea")
    if (field) field.focus()
  }

  close() {
    if (!this.hasOverlayTarget) return

    this.overlayTarget.classList.remove("is-open")
    document.body.classList.remove("ps-modal-open")
    // Wait for the fade-out before hiding so the transition is visible.
    setTimeout(() => { this.overlayTarget.hidden = true }, 180)
  }

  // Close only when the click lands on the backdrop itself, not the card.
  backdrop(event) {
    if (event.target === this.overlayTarget) this.close()
  }
}
