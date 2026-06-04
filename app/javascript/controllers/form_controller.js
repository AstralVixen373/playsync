import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    // On annule le timer précédent s'il existe
    clearTimeout(this.timeout)

    // On attend 300ms après la fin de la frappe avant d'envoyer la requête
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}
