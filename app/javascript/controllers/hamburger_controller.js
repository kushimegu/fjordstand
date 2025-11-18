import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "nav"]

  toggle() {
    this.buttonTarget.classList.toggle("bg-gray-100")
    this.buttonTarget.classList.toggle("rounded")
    this.navTarget.classList.toggle("hidden")
  }
}
