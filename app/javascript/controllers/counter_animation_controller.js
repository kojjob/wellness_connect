import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["number"]
  static values = {
    start: { type: Number, default: 0 },
    end: { type: Number, default: 100 },
    duration: { type: Number, default: 2000 },
    suffix: { type: String, default: "" },
    decimals: { type: Number, default: 0 }
  }

  connect() {
    this.hasAnimated = false
    this.setupIntersectionObserver()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  setupIntersectionObserver() {
    const options = {
      threshold: 0.5,
      rootMargin: "0px"
    }

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.hasAnimated) {
          this.animate()
        }
      })
    }, options)

    this.observer.observe(this.element)
  }

  animate() {
    if (this.hasAnimated) return
    
    this.hasAnimated = true
    const start = this.startValue
    const end = this.endValue
    const duration = this.durationValue
    const suffix = this.suffixValue
    const decimals = this.decimalsValue

    this.animateValue(this.numberTarget, start, end, duration, suffix, decimals)
  }

  animateValue(element, start, end, duration, suffix, decimals) {
    const range = end - start
    const increment = range / (duration / 16) // 60fps
    let current = start
    const startTime = performance.now()

    const updateCounter = (currentTime) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)
      
      current = start + (range * this.easeOutQuad(progress))
      
      const formattedValue = this.formatNumber(current, decimals)
      element.textContent = formattedValue + suffix
      
      if (progress < 1) {
        requestAnimationFrame(updateCounter)
      } else {
        element.textContent = this.formatNumber(end, decimals) + suffix
      }
    }

    requestAnimationFrame(updateCounter)
  }

  easeOutQuad(t) {
    return t * (2 - t)
  }

  formatNumber(num, decimals) {
    const fixed = num.toFixed(decimals)
    const parts = fixed.split('.')
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',')
    return parts.join('.')
  }
}

