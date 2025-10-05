import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="carousel"
export default class extends Controller {
  static targets = ["slide", "indicator"]
  static values = {
    currentIndex: { type: Number, default: 0 },
    autoplay: { type: Boolean, default: false },
    interval: { type: Number, default: 5000 }
  }

  connect() {
    console.log("Carousel controller connected")
    this.showSlide(this.currentIndexValue)
    
    if (this.autoplayValue) {
      this.startAutoplay()
    }
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
        slide.classList.remove("hidden")
        slide.classList.add("block")
      } else {
        slide.classList.add("hidden")
        slide.classList.remove("block")
      }
    })

    // Update indicators
    if (this.hasIndicatorTarget) {
      this.indicatorTargets.forEach((indicator, i) => {
        if (i === index) {
          indicator.classList.add("bg-indigo-600")
          indicator.classList.remove("bg-gray-300")
        } else {
          indicator.classList.remove("bg-indigo-600")
          indicator.classList.add("bg-gray-300")
        }
      })
    }
  }

  startAutoplay() {
    this.autoplayTimer = setInterval(() => {
      this.next()
    }, this.intervalValue)
  }

  stopAutoplay() {
    if (this.autoplayTimer) {
      clearInterval(this.autoplayTimer)
    }
  }

  resetAutoplay() {
    if (this.autoplayValue) {
      this.stopAutoplay()
      this.startAutoplay()
    }
  }
}

