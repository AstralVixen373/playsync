import { Controller } from "@hotwired/stimulus"

// A closed dropdown that supports multiple selection through checkboxes.
// The toggle button shows the current selection; the panel opens on click and
// closes when clicking outside. Checkbox `change` events bubble up, so a parent
// form with `change->form#submit` auto-submits as usual.
export default class extends Controller {
  static targets = ["toggle", "panel"]
  static values = { placeholder: { type: String, default: "All" } }

  connect() {
    this.updateLabel()
    this.closeOnOutsideClick = (event) => {
      if (!this.element.contains(event.target)) this.close()
    }
    document.addEventListener("click", this.closeOnOutsideClick)
    // Allow other controllers (e.g. a reset button) to refresh the label.
    this.refresh = () => this.updateLabel()
    this.element.addEventListener("multiselect:refresh", this.refresh)
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
    this.element.removeEventListener("multiselect:refresh", this.refresh)
  }

  toggle(event) {
    event.preventDefault()
    this.panelTarget.hidden = !this.panelTarget.hidden
  }

  close() {
    this.panelTarget.hidden = true
  }

  update() {
    this.updateLabel()
  }

  updateLabel() {
    const selected = Array.from(
      this.panelTarget.querySelectorAll("input[type=checkbox]:checked")
    ).map((checkbox) => checkbox.value)

    this.toggleTarget.textContent = selected.length
      ? selected.join(", ")
      : this.placeholderValue
  }
}
