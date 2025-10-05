import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="carousel"
export default class extends Controller {
  static targets = ["container", "slide", "prevButton", "nextButton", "indicator"]
  static values = {
    index: { type: Number, default: 0 },
    autoplay: { type: Boolean, default: false },
    interval: { type: Number, default: 5000 },
    slidesToShow: { type: Number, default: 4 },
    slidesToShowTablet: { type: Number, default: 2 },
    slidesToShowMobile: { type: Number, default: 1 }
  }

  connect() {
    // Check for reduced motion preference
    this.prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

    // Initialize carousel
    this.currentIndex = this.indexValue
    this.touchStartX = 0
    this.touchEndX = 0
    this.autoplayTimer = null

    // Set up responsive behavior
    this.updateSlidesToShow()
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.handleResize)

    // Set up touch events for mobile
    this.containerTarget.addEventListener('touchstart', this.handleTouchStart.bind(this), { passive: true })
    this.containerTarget.addEventListener('touchmove', this.handleTouchMove.bind(this), { passive: true })
    this.containerTarget.addEventListener('touchend', this.handleTouchEnd.bind(this))

    // Initial render
    this.updateCarousel()
    this.updateIndicators()
    this.updateButtons()

    // Start autoplay if enabled
    if (this.autoplayValue && !this.prefersReducedMotion) {
      this.startAutoplay()
    }
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize)
    this.stopAutoplay()
  }

  // Navigation methods
  next() {
    const maxIndex = this.slideTargets.length - this.slidesToShow
    if (this.currentIndex < maxIndex) {
      this.currentIndex++
      this.updateCarousel()
    }
  }

  previous() {
    if (this.currentIndex > 0) {
      this.currentIndex--
      this.updateCarousel()
    }
  }

  goToSlide(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.currentIndex = index
    this.updateCarousel()
  }

  // Update carousel position
  updateCarousel() {
    const slideWidth = this.slideTargets[0].offsetWidth
    const gap = 24 // 1.5rem gap between slides
    const offset = -(this.currentIndex * (slideWidth + gap))

    const duration = this.prefersReducedMotion ? '0ms' : '500ms'
    this.containerTarget.style.transition = `transform ${duration} cubic-bezier(0.4, 0, 0.2, 1)`
    this.containerTarget.style.transform = `translateX(${offset}px)`

    this.updateIndicators()
    this.updateButtons()
  }

  // Update indicator dots
  updateIndicators() {
    if (!this.hasIndicatorTarget) return

    this.indicatorTargets.forEach((indicator, index) => {
      if (index === this.currentIndex) {
        indicator.classList.add('bg-indigo-600', 'w-8')
        indicator.classList.remove('bg-gray-300', 'w-2')
      } else {
        indicator.classList.remove('bg-indigo-600', 'w-8')
        indicator.classList.add('bg-gray-300', 'w-2')
      }
    })
  }

  // Update button states
  updateButtons() {
    const maxIndex = this.slideTargets.length - this.slidesToShow

    // Update previous button
    if (this.hasPrevButtonTarget) {
      if (this.currentIndex === 0) {
        this.prevButtonTarget.disabled = true
        this.prevButtonTarget.classList.add('opacity-50', 'cursor-not-allowed')
      } else {
        this.prevButtonTarget.disabled = false
        this.prevButtonTarget.classList.remove('opacity-50', 'cursor-not-allowed')
      }
    }

    // Update next button
    if (this.hasNextButtonTarget) {
      if (this.currentIndex >= maxIndex) {
        this.nextButtonTarget.disabled = true
        this.nextButtonTarget.classList.add('opacity-50', 'cursor-not-allowed')
      } else {
        this.nextButtonTarget.disabled = false
        this.nextButtonTarget.classList.remove('opacity-50', 'cursor-not-allowed')
      }
    }
  }

  // Touch/swipe handling
  handleTouchStart(event) {
    this.touchStartX = event.changedTouches[0].screenX
  }

  handleTouchMove(event) {
    this.touchEndX = event.changedTouches[0].screenX
  }

  handleTouchEnd() {
    const swipeThreshold = 50
    const diff = this.touchStartX - this.touchEndX

    if (Math.abs(diff) > swipeThreshold) {
      if (diff > 0) {
        // Swiped left - go to next
        this.next()
      } else {
        // Swiped right - go to previous
        this.previous()
      }
    }
  }

  // Responsive behavior
  handleResize() {
    this.updateSlidesToShow()
    this.updateCarousel()
  }

  updateSlidesToShow() {
    const width = window.innerWidth

    if (width < 768) {
      // Mobile
      this.slidesToShow = this.slidesToShowMobileValue
    } else if (width < 1024) {
      // Tablet
      this.slidesToShow = this.slidesToShowTabletValue
    } else {
      // Desktop
      this.slidesToShow = this.slidesToShowValue
    }
  }

  // Autoplay functionality
  startAutoplay() {
    this.autoplayTimer = setInterval(() => {
      const maxIndex = this.slideTargets.length - this.slidesToShow
      if (this.currentIndex >= maxIndex) {
        this.currentIndex = 0
      } else {
        this.currentIndex++
      }
      this.updateCarousel()
    }, this.intervalValue)
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

  // Keyboard navigation
  handleKeydown(event) {
    switch(event.key) {
      case 'ArrowLeft':
        event.preventDefault()
        this.previous()
        break
      case 'ArrowRight':
        event.preventDefault()
        this.next()
        break
      case 'Home':
        event.preventDefault()
        this.currentIndex = 0
        this.updateCarousel()
        break
      case 'End':
        event.preventDefault()
        this.currentIndex = this.slideTargets.length - this.slidesToShow
        this.updateCarousel()
        break
    }
  }
}
