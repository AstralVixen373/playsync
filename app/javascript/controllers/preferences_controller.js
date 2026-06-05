import { Controller } from "@hotwired/stimulus"

// Clears every filter-preference field inside the wrapped fieldset. The user
// still has to submit the form to persist the cleared preferences.
export default class extends Controller {
  reset(event) {
    event.preventDefault()

    this.element.querySelectorAll("input[type=checkbox]").forEach((cb) => {
      cb.checked = false
    })

    // Single-value selects (e.g. language) fall back to their first/blank option.
    this.element.querySelectorAll("select").forEach((select) => {
      select.selectedIndex = 0
    })

    // Remove game chips (the always-present empty hidden input stays, so the
    // preference is saved as empty).
    this.element.querySelectorAll(".game-chip").forEach((chip) => chip.remove())

    // Refresh every multi-select toggle label.
    this.element.querySelectorAll("[data-controller~='multiselect']").forEach((el) => {
      el.dispatchEvent(new CustomEvent("multiselect:refresh"))
    })
  }
}
