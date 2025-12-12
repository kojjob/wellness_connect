import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="booking-form"
export default class extends Controller {
  static targets = ["submitButton", "spinner", "form"]

  connect() {
    // Controller initialized
  }

  // Escape HTML to prevent XSS attacks
  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  submit(event) {
    // Check if a time slot is selected
    const selectedSlot = this.formTarget.querySelector('input[name="selected_time_slot"]:checked')
    
    if (!selectedSlot) {
      event.preventDefault()
      this.showError("Please select a time slot before booking")
      return
    }

    // Show loading state
    this.showLoading()
  }

  showLoading() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add('opacity-75', 'cursor-not-allowed')
      
      // Update button text
      const originalText = this.submitButtonTarget.textContent
      this.submitButtonTarget.dataset.originalText = originalText
      this.submitButtonTarget.innerHTML = `
        <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white inline-block" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        Processing...
      `
    }
  }

  showError(message) {
    // Create error alert
    const errorDiv = document.createElement('div')
    errorDiv.className = 'mb-6 bg-red-50 border-l-4 border-red-500 rounded-lg p-4 shadow-md'
    errorDiv.setAttribute('role', 'alert')
    errorDiv.innerHTML = `
      <div class="flex items-start">
        <svg class="w-6 h-6 text-red-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
        </svg>
        <div class="flex-1">
          <h3 class="text-sm font-bold text-red-800 mb-1">Validation Error</h3>
          <p class="text-sm text-red-700" id="error-message"></p>
        </div>
        <button type="button" onclick="this.parentElement.parentElement.remove()" class="ml-3 flex-shrink-0 text-red-500 hover:text-red-700" aria-label="Dismiss">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
      </div>
    `

    // Safely set error message using textContent to prevent XSS
    const messageEl = errorDiv.querySelector('#error-message')
    if (messageEl) {
      messageEl.textContent = message
    }

    // Insert error before form
    this.formTarget.parentElement.insertBefore(errorDiv, this.formTarget)

    // Scroll to error
    errorDiv.scrollIntoView({ behavior: 'smooth', block: 'center' })

    // Auto-dismiss after 5 seconds
    setTimeout(() => {
      errorDiv.remove()
    }, 5000)
  }
}

