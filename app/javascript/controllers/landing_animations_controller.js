import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="landing-animations"
export default class extends Controller {
  static targets = ["fadeIn", "slideLeft", "slideRight", "slideUp", "scale", "stagger"]
  static values = {
    threshold: { type: Number, default: 0.1 },
    rootMargin: { type: String, default: "0px 0px -100px 0px" }
  }

  connect() {
    // Check if user prefers reduced motion
    this.prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    
    if (this.prefersReducedMotion) {
      // Skip animations if user prefers reduced motion
      this.showAllElements()
      return
    }

    // Initialize Intersection Observer for scroll-triggered animations
    this.observer = new IntersectionObserver(
      (entries) => this.handleIntersection(entries),
      {
        threshold: this.thresholdValue,
        rootMargin: this.rootMarginValue
      }
    )

    // Observe all animation targets
    this.observeElements()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  observeElements() {
    // Observe fade-in elements
    this.fadeInTargets.forEach((element, index) => {
      element.style.opacity = "0"
      element.style.transition = "opacity 0.8s ease-out"
      this.observer.observe(element)
    })

    // Observe slide-left elements
    this.slideLeftTargets.forEach((element, index) => {
      element.style.opacity = "0"
      element.style.transform = "translateX(-50px)"
      element.style.transition = "opacity 0.8s ease-out, transform 0.8s ease-out"
      this.observer.observe(element)
    })

    // Observe slide-right elements
    this.slideRightTargets.forEach((element, index) => {
      element.style.opacity = "0"
      element.style.transform = "translateX(50px)"
      element.style.transition = "opacity 0.8s ease-out, transform 0.8s ease-out"
      this.observer.observe(element)
    })

    // Observe slide-up elements
    this.slideUpTargets.forEach((element, index) => {
      element.style.opacity = "0"
      element.style.transform = "translateY(50px)"
      element.style.transition = "opacity 0.8s ease-out, transform 0.8s ease-out"
      this.observer.observe(element)
    })

    // Observe scale elements
    this.scaleTargets.forEach((element, index) => {
      element.style.opacity = "0"
      element.style.transform = "scale(0.9)"
      element.style.transition = "opacity 0.8s ease-out, transform 0.8s ease-out"
      this.observer.observe(element)
    })

    // Observe stagger elements (children animate in sequence)
    this.staggerTargets.forEach((container) => {
      const children = Array.from(container.children)
      children.forEach((child, index) => {
        child.style.opacity = "0"
        child.style.transform = "translateY(20px)"
        child.style.transition = `opacity 0.6s ease-out ${index * 0.1}s, transform 0.6s ease-out ${index * 0.1}s`
        child.dataset.staggerChild = "true"
      })
      this.observer.observe(container)
    })
  }

  handleIntersection(entries) {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        this.animateElement(entry.target)
        // Stop observing once animated (one-time animation)
        this.observer.unobserve(entry.target)
      }
    })
  }

  animateElement(element) {
    // Check if this is a stagger container
    if (this.staggerTargets.includes(element)) {
      const children = Array.from(element.children).filter(
        child => child.dataset.staggerChild === "true"
      )
      children.forEach((child) => {
        child.style.opacity = "1"
        child.style.transform = "translateY(0)"
      })
    } else {
      // Animate individual element
      element.style.opacity = "1"
      element.style.transform = "translateX(0) translateY(0) scale(1)"
    }
  }

  showAllElements() {
    // Show all elements immediately without animation
    const allTargets = [
      ...this.fadeInTargets,
      ...this.slideLeftTargets,
      ...this.slideRightTargets,
      ...this.slideUpTargets,
      ...this.scaleTargets
    ]

    allTargets.forEach((element) => {
      element.style.opacity = "1"
      element.style.transform = "none"
    })

    this.staggerTargets.forEach((container) => {
      const children = Array.from(container.children)
      children.forEach((child) => {
        child.style.opacity = "1"
        child.style.transform = "none"
      })
    })
  }
}

