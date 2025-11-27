import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="rating-selector"
export default class extends Controller {
  static targets = [ "star", "input" ]

  connect() {
  }

  update(event) {
    const rating = parseInt(event.target.value)

    this.starTargets.forEach((star, index) => {
      if (index < rating) {
        star.classList.remove("text-gray-300")
        star.classList.add("text-yellow-400")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-300")
      }
    })
  }
}
