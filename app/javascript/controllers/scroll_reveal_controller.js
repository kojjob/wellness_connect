import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll-reveal"
export default class extends Controller {
  static targets = ["element"]

  connect() {
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("revealed")
            // Optionally unobserve after revealing
            this.observer.unobserve(entry.target)
          }
        })
      },
      {
        threshold: 0.1,
        rootMargin: "0px 0px -50px 0px"
      }
    )

    this.elementTargets.forEach((element) => {
      this.observer.observe(element)
    })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}

