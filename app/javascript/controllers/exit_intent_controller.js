import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "modal"]
  static values = {
    delay: { type: Number, default: 5000 }
  }

  connect() {
    // Check if popup was already shown today
    if (this.getCookie("exit_intent_shown")) {
      return
    }

    // Wait for delay before activating
    setTimeout(() => {
      this.activated = true
      this.setupExitIntent()
    }, this.delayValue)
  }

  disconnect() {
    if (this.handleMouseLeave) {
      document.removeEventListener('mouseleave', this.handleMouseLeave)
    }
  }

  setupExitIntent() {
    this.handleMouseLeave = (event) => {
      // Check if mouse is leaving from the top of the page
      if (event.clientY <= 0 && !this.shown) {
        this.show()
      }
    }

    document.addEventListener('mouseleave', this.handleMouseLeave)
  }

  show() {
    if (this.shown) return
    
    this.shown = true
    this.element.classList.remove('hidden')
    
    // Animate overlay
    requestAnimationFrame(() => {
      this.overlayTarget.style.opacity = '0.75'
      
      // Animate modal
      this.modalTarget.style.opacity = '1'
      this.modalTarget.style.transform = 'scale(1)'
    })

    // Set cookie so it doesn't show again for 24 hours
    this.setCookie("exit_intent_shown", "true", 1)
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }

    // Animate out
    this.overlayTarget.style.opacity = '0'
    this.modalTarget.style.opacity = '0'
    this.modalTarget.style.transform = 'scale(0.95)'

    setTimeout(() => {
      this.element.classList.add('hidden')
    }, 300)
  }

  closeOnOverlay(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }

  getCookie(name) {
    const value = `; ${document.cookie}`
    const parts = value.split(`; ${name}=`)
    if (parts.length === 2) return parts.pop().split(';').shift()
    return null
  }

  setCookie(name, value, days) {
    const expires = new Date()
    expires.setTime(expires.getTime() + (days * 24 * 60 * 60 * 1000))
    document.cookie = `${name}=${value};expires=${expires.toUTCString()};path=/`
  }
}

