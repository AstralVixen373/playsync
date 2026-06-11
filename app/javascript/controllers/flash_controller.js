import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar"]

  connect() {
    requestAnimationFrame(() => {
      this.barTarget.style.width = "0%"
    })
    this.timer = setTimeout(() => this.dismiss(), 3000)
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  dismiss() {
    this.element.style.transition = "opacity 0.3s ease, transform 0.3s ease"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(6px)"
    setTimeout(() => this.element.remove(), 300)
  }
}
