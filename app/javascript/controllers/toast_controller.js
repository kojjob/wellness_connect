import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  static values = {
    autoDismiss: { type: Boolean, default: true },
    duration: { type: Number, default: 5000 }, // 5 seconds
    dismissDelay: { type: Number, default: 300 } // Animation duration
  }

  connect() {
    // Set initial animation state
    this.element.classList.add("toast-enter")

    // Use double requestAnimationFrame for more reliable animation triggering
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this.element.classList.remove("toast-enter")
        this.element.classList.add("toast-enter-active")
      })
    })

    // Auto-dismiss if enabled
    if (this.autoDismissValue) {
      this.autoDismissTimer = setTimeout(() => {
        this.dismiss()
      }, this.durationValue)
    }
  }

  disconnect() {
    // Clear auto-dismiss timer if exists
    if (this.autoDismissTimer) {
      clearTimeout(this.autoDismissTimer)
    }
  }

  dismiss() {
    // Cancel auto-dismiss timer
    if (this.autoDismissTimer) {
      clearTimeout(this.autoDismissTimer)
    }

    // Add exit animation classes
    this.element.classList.remove("toast-enter-active")
    this.element.classList.add("toast-exit", "toast-exit-active")

    // Remove element after animation completes
    setTimeout(() => {
      this.element.remove()
    }, this.dismissDelayValue)
  }

  // Pause auto-dismiss on hover
  pauseAutoDismiss() {
    if (this.autoDismissTimer) {
      clearTimeout(this.autoDismissTimer)
    }
  }

  // Resume auto-dismiss on mouse leave
  resumeAutoDismiss() {
    if (this.autoDismissValue) {
      this.autoDismissTimer = setTimeout(() => {
        this.dismiss()
      }, this.durationValue)
    }
  }
}
