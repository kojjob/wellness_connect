import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="share"
export default class extends Controller {
  static values = {
    title: String,
    text: String,
    url: String
  }

  connect() {
    console.log("Share controller connected")
  }

  async share(event) {
    event.preventDefault()

    const shareData = {
      title: this.titleValue || document.title,
      text: this.textValue || "Check out this provider on WellnessConnect",
      url: this.urlValue || window.location.href
    }

    // Check if Web Share API is supported
    if (navigator.share) {
      try {
        await navigator.share(shareData)
        this.showToast("Shared successfully!", "success")
      } catch (err) {
        // User cancelled or error occurred
        if (err.name !== 'AbortError') {
          console.error('Error sharing:', err)
          this.fallbackShare(shareData.url)
        }
      }
    } else {
      // Fallback to copy to clipboard
      this.fallbackShare(shareData.url)
    }
  }

  fallbackShare(url) {
    // Copy URL to clipboard
    navigator.clipboard.writeText(url).then(() => {
      this.showToast("Link copied to clipboard!", "success")
    }).catch(err => {
      console.error('Failed to copy:', err)
      this.showToast("Failed to copy link", "error")
    })
  }

  showToast(message, type = "success") {
    // Create toast notification
    const toast = document.createElement('div')
    toast.className = `fixed bottom-6 left-1/2 transform -translate-x-1/2 px-6 py-3 rounded-lg shadow-lg text-white font-medium z-50 transition-all duration-300 ${
      type === 'success' ? 'bg-green-500' : 'bg-red-500'
    }`
    toast.textContent = message
    toast.style.opacity = '0'
    toast.style.transform = 'translate(-50%, 20px)'

    document.body.appendChild(toast)

    // Animate in
    requestAnimationFrame(() => {
      toast.style.opacity = '1'
      toast.style.transform = 'translate(-50%, 0)'
    })

    // Remove after 3 seconds
    setTimeout(() => {
      toast.style.opacity = '0'
      toast.style.transform = 'translate(-50%, 20px)'
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }
}

