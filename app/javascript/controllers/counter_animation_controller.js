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
    this.observer = new IntersectionObserver(
      (entries) => this.handleIntersection(entries),
      { threshold: 0.5 }
    )
    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting && !this.hasAnimated) {
        this.animate()
        this.hasAnimated = true
      }
    })
  }

  animate() {
    this.numberTargets.forEach(target => {
      const endValue = parseFloat(target.dataset.counterAnimationEndValue || this.endValue)
      const startValue = parseFloat(target.dataset.counterAnimationStartValue || this.startValue)
      const duration = parseInt(target.dataset.counterAnimationDurationValue || this.durationValue)
      const suffix = target.dataset.counterAnimationSuffixValue || this.suffixValue
      const decimals = parseInt(target.dataset.counterAnimationDecimalsValue || this.decimalsValue)
      
      this.animateValue(target, startValue, endValue, duration, suffix, decimals)
    })
  }

  animateValue(element, start, end, duration, suffix, decimals) {
    const range = end - start
    const increment = range / (duration / 16) // 60fps
    let current = start
    
    const timer = setInterval(() => {
      current += increment
      
      if ((increment > 0 && current >= end) || (increment < 0 && current <= end)) {
        current = end
        clearInterval(timer)
      }
      
      const displayValue = decimals > 0 
        ? current.toFixed(decimals)
        : Math.floor(current).toLocaleString()
      
      element.textContent = displayValue + suffix
    }, 16)
  }
}

