import { Controller } from "@hotwired/stimulus"

// Drives the profile avatar card: opens the (hidden) file picker, previews the
// chosen image, and handles the "Remove" button. Removal sets a hidden flag the
// server reads to purge the existing avatar — the file input itself stays empty.
export default class extends Controller {
  static targets = ["input", "preview", "removeFlag"]
  static values = { initial: String }

  choose() {
    this.inputTarget.click()
  }

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    // A new file always wins over a pending removal.
    if (this.hasRemoveFlagTarget) this.removeFlagTarget.value = ""

    const reader = new FileReader()
    reader.onload = (event) => this.#renderImage(event.target.result)
    reader.readAsDataURL(file)
  }

  remove() {
    this.inputTarget.value = ""
    if (this.hasRemoveFlagTarget) this.removeFlagTarget.value = "1"
    this.#renderInitial()
  }

  #renderImage(src) {
    this.previewTarget.innerHTML = ""
    const img = document.createElement("img")
    img.src = src
    img.alt = "Avatar"
    this.previewTarget.appendChild(img)
  }

  #renderInitial() {
    this.previewTarget.innerHTML = ""
    this.previewTarget.textContent = this.initialValue
  }
}
