import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="counter"
export default class extends Controller {
  static targets = ["number"]
  static values = {
    end: Number,
    duration: { type: Number, default: 2000 },
    suffix: { type: String, default: "" }
  }

  connect() {
    this.hasAnimated = false
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting && !this.hasAnimated) {
            this.animate()
            this.hasAnimated = true
          }
        })
      },
      { threshold: 0.5 }
    )

    this.observer.observe(this.element)
  }

  animate() {
    const start = 0
    const end = this.endValue
    const duration = this.durationValue
    const startTime = performance.now()

    const updateCounter = (currentTime) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)

      // Easing function for smooth animation
      const easeOutQuart = 1 - Math.pow(1 - progress, 4)
      const current = Math.floor(easeOutQuart * end)

      this.numberTarget.textContent = this.formatNumber(current) + this.suffixValue

      if (progress < 1) {
        requestAnimationFrame(updateCounter)
      } else {
        this.numberTarget.textContent = this.formatNumber(end) + this.suffixValue
      }
    }

    requestAnimationFrame(updateCounter)
  }

  formatNumber(num) {
    if (num >= 1000) {
      return (num / 1000).toFixed(0) + "K"
    }
    return num.toString()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}

