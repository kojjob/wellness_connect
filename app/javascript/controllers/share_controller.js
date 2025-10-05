import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="share"
export default class extends Controller {
  static values = {
    url: String,
    title: String,
    text: String
  }

  connect() {
    console.log("Share controller connected")
  }

  async shareProfile(event) {
    event.preventDefault()

    const shareData = {
      title: this.titleValue,
      text: this.textValue,
      url: this.urlValue
    }

    // Check if Web Share API is supported
    if (navigator.share) {
      try {
        await navigator.share(shareData)
        console.log("Profile shared successfully")
      } catch (error) {
        if (error.name !== 'AbortError') {
          console.error("Error sharing:", error)
          this.fallbackShare()
        }
      }
    } else {
      // Fallback for browsers that don't support Web Share API
      this.fallbackShare()
    }
  }

  fallbackShare() {
    // Copy URL to clipboard
    navigator.clipboard.writeText(this.urlValue).then(() => {
      // Show success message
      this.showToast("Profile link copied to clipboard!")
    }).catch(err => {
      console.error("Failed to copy:", err)
      // Show the URL in a prompt as last resort
      prompt("Copy this link to share:", this.urlValue)
    })
  }

  showToast(message) {
    // Create toast notification
    const toast = document.createElement('div')
    toast.className = 'fixed bottom-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg z-50 animate-slide-up'
    toast.textContent = message
    
    document.body.appendChild(toast)
    
    // Remove after 3 seconds
    setTimeout(() => {
      toast.classList.add('opacity-0', 'transition-opacity', 'duration-300')
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }
}

