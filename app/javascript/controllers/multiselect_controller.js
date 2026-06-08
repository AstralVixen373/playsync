import { Controller } from "@hotwired/stimulus"

// A closed dropdown that supports multiple selection through checkboxes.
// The toggle button shows the current selection; the panel opens on click and
// closes when clicking outside. Checkbox `change` events bubble up, so a parent
// form with `change->form#submit` auto-submits as usual.
export default class extends Controller {
  static targets = ["toggle", "panel"]
  static values = {
    placeholder: { type: String, default: "All" },
    single: { type: Boolean, default: false }
  }

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

  update(event) {
    // Single-select keeps checkbox styling but behaves like a radio group:
    // ticking one option clears the others, then the dropdown closes.
    if (this.singleValue && event.target.checked) {
      this.panelTarget
        .querySelectorAll("input[type=checkbox]")
        .forEach((box) => {
          if (box !== event.target) box.checked = false
        })
    }

    this.updateLabel()
    if (this.singleValue) this.close()
  }

  updateLabel() {
    const checked = Array.from(
      this.panelTarget.querySelectorAll("input:checked")
    ).filter((input) => input.value !== "")

    if (checked.length === 0) {
      this.toggleTarget.textContent = this.placeholderValue
      return
    }

    // Mirror each selected option's icon (if its label has one) next to its
    // value, so the summary stays consistent with the open dropdown.
    this.toggleTarget.innerHTML = checked
      .map((input) => {
        const icon = input.closest("label")?.querySelector(".platform-icon")
        const iconHtml = icon ? icon.outerHTML : ""
        const text = document.createElement("span")
        text.textContent = input.value
        return `<span style="display:inline-flex;align-items:center;gap:0.3rem;">${iconHtml}${text.outerHTML}</span>`
      })
      .join(`<span style="opacity:.5;">,&nbsp;</span>`)
  }
}
