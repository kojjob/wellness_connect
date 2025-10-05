import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "overlay"]
  static values = {
    delay: { type: Number, default: 3000 } // Don't show immediately
  }

  connect() {
    // Check if user has already seen the modal today
    if (this.hasSeenToday()) {
      return
    }

    // Wait a bit before activating exit intent
    setTimeout(() => {
      this.handleMouseLeave = this.handleMouseLeave.bind(this)
      document.addEventListener('mouseleave', this.handleMouseLeave)
    }, this.delayValue)
  }

  disconnect() {
    document.removeEventListener('mouseleave', this.handleMouseLeave)
  }

  handleMouseLeave(event) {
    // Only trigger if mouse leaves from the top of the page
    if (event.clientY < 0) {
      this.show()
    }
  }

  show() {
    // Remove event listener so it only shows once
    document.removeEventListener('mouseleave', this.handleMouseLeave)
    
    this.element.classList.remove('hidden')
    
    // Animate in
    setTimeout(() => {
      this.overlayTarget.classList.remove('opacity-0')
      this.overlayTarget.classList.add('opacity-100')
      this.modalTarget.classList.remove('opacity-0', 'scale-95')
      this.modalTarget.classList.add('opacity-100', 'scale-100')
    }, 10)
    
    // Set cookie so we don't show again today
    this.setSeenCookie()
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }
    
    // Animate out
    this.overlayTarget.classList.remove('opacity-100')
    this.overlayTarget.classList.add('opacity-0')
    this.modalTarget.classList.remove('opacity-100', 'scale-100')
    this.modalTarget.classList.add('opacity-0', 'scale-95')
    
    setTimeout(() => {
      this.element.classList.add('hidden')
    }, 300)
  }

  closeOnOverlay(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }

  hasSeenToday() {
    const cookies = document.cookie.split(';')
    return cookies.some(cookie => cookie.trim().startsWith('exit_intent_seen='))
  }

  setSeenCookie() {
    // Set cookie to expire at end of day
    const now = new Date()
    const endOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59)
    const maxAge = Math.floor((endOfDay - now) / 1000)
    document.cookie = `exit_intent_seen=true; max-age=${maxAge}; path=/`
  }
}

