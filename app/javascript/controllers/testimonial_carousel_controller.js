import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="testimonial-carousel"
export default class extends Controller {
  static targets = ["slide", "indicator", "prevButton", "nextButton"]
  static values = {
    autoplay: { type: Boolean, default: true },
    interval: { type: Number, default: 5000 },
    currentIndex: { type: Number, default: 0 }
  }

  connect() {
    this.prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.showSlide(this.currentIndexValue)
    
    if (this.autoplayValue && !this.prefersReducedMotion) {
      this.startAutoplay()
    }

    // Pause autoplay on hover
    this.element.addEventListener("mouseenter", () => this.pauseAutoplay())
    this.element.addEventListener("mouseleave", () => this.resumeAutoplay())

    // Handle keyboard navigation
    this.element.addEventListener("keydown", (e) => this.handleKeyboard(e))
  }

  disconnect() {
    this.stopAutoplay()
  }

  next() {
    this.currentIndexValue = (this.currentIndexValue + 1) % this.slideTargets.length
    this.showSlide(this.currentIndexValue)
    this.resetAutoplay()
  }

  previous() {
    this.currentIndexValue = (this.currentIndexValue - 1 + this.slideTargets.length) % this.slideTargets.length
    this.showSlide(this.currentIndexValue)
    this.resetAutoplay()
  }

  goToSlide(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.currentIndexValue = index
    this.showSlide(index)
    this.resetAutoplay()
  }

  showSlide(index) {
    // Hide all slides
    this.slideTargets.forEach((slide, i) => {
      if (i === index) {
        slide.classList.remove("hidden", "opacity-0")
        slide.classList.add("opacity-100")
        slide.setAttribute("aria-hidden", "false")
      } else {
        slide.classList.add("hidden", "opacity-0")
        slide.classList.remove("opacity-100")
        slide.setAttribute("aria-hidden", "true")
      }
    })

    // Update indicators
    if (this.hasIndicatorTarget) {
      this.indicatorTargets.forEach((indicator, i) => {
        if (i === index) {
          indicator.classList.add("bg-indigo-600")
          indicator.classList.remove("bg-gray-300")
          indicator.setAttribute("aria-current", "true")
        } else {
          indicator.classList.remove("bg-indigo-600")
          indicator.classList.add("bg-gray-300")
          indicator.setAttribute("aria-current", "false")
        }
      })
    }

    // Update button states
    this.updateButtonStates()
  }

  updateButtonStates() {
    // Enable/disable prev/next buttons at boundaries (optional)
    // For infinite carousel, buttons are always enabled
    if (this.hasPrevButtonTarget) {
      this.prevButtonTarget.disabled = false
    }
    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.disabled = false
    }
  }

  startAutoplay() {
    if (this.autoplayValue && !this.prefersReducedMotion) {
      this.autoplayTimer = setInterval(() => {
        this.next()
      }, this.intervalValue)
    }
  }

  stopAutoplay() {
    if (this.autoplayTimer) {
      clearInterval(this.autoplayTimer)
      this.autoplayTimer = null
    }
  }

  pauseAutoplay() {
    this.stopAutoplay()
  }

  resumeAutoplay() {
    if (this.autoplayValue && !this.prefersReducedMotion) {
      this.startAutoplay()
    }
  }

  resetAutoplay() {
    this.stopAutoplay()
    if (this.autoplayValue && !this.prefersReducedMotion) {
      this.startAutoplay()
    }
  }

  handleKeyboard(event) {
    switch(event.key) {
      case "ArrowLeft":
        event.preventDefault()
        this.previous()
        break
      case "ArrowRight":
        event.preventDefault()
        this.next()
        break
    }
  }
}

