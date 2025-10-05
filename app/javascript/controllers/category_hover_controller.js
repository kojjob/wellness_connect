import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="category-hover"
export default class extends Controller {
  static targets = ["card", "icon", "title", "description"]

  connect() {
    this.prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    
    if (!this.prefersReducedMotion) {
      this.setupAnimations()
    }
  }

  setupAnimations() {
    // Add smooth transitions to all cards
    this.cardTargets.forEach((card) => {
      card.style.transition = "transform 0.3s ease-out, box-shadow 0.3s ease-out"
    })

    // Add transitions to icons
    this.iconTargets.forEach((icon) => {
      icon.style.transition = "transform 0.3s ease-out"
    })
  }

  mouseEnter(event) {
    if (this.prefersReducedMotion) return

    const card = event.currentTarget
    const cardIndex = this.cardTargets.indexOf(card)
    const icon = this.iconTargets[cardIndex]

    // Lift card
    card.style.transform = "translateY(-8px)"
    
    // Scale icon
    if (icon) {
      icon.style.transform = "scale(1.1) rotate(5deg)"
    }

    // Add enhanced shadow (handled by Tailwind hover classes)
  }

  mouseLeave(event) {
    if (this.prefersReducedMotion) return

    const card = event.currentTarget
    const cardIndex = this.cardTargets.indexOf(card)
    const icon = this.iconTargets[cardIndex]

    // Reset card position
    card.style.transform = "translateY(0)"
    
    // Reset icon
    if (icon) {
      icon.style.transform = "scale(1) rotate(0deg)"
    }
  }

  // Tilt effect on mouse move (optional, subtle 3D effect)
  mouseMove(event) {
    if (this.prefersReducedMotion) return

    const card = event.currentTarget
    const rect = card.getBoundingClientRect()
    const x = event.clientX - rect.left
    const y = event.clientY - rect.top
    
    const centerX = rect.width / 2
    const centerY = rect.height / 2
    
    const rotateX = (y - centerY) / 20
    const rotateY = (centerX - x) / 20

    // Subtle tilt effect
    card.style.transform = `translateY(-8px) perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`
  }

  // Reset tilt on mouse leave
  resetTilt(event) {
    if (this.prefersReducedMotion) return

    const card = event.currentTarget
    card.style.transform = "translateY(0) perspective(1000px) rotateX(0deg) rotateY(0deg)"
  }
}

