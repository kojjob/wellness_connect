import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="message"
export default class extends Controller {
  connect() {
    console.log("Message controller connected")
  }

  showComingSoon(event) {
    event.preventDefault()
    this.showToast("Messaging feature coming soon! 💬")
  }

  showToast(message) {
    // Create toast notification
    const toast = document.createElement('div')
    toast.className = 'fixed bottom-4 right-4 bg-indigo-500 text-white px-6 py-3 rounded-lg shadow-lg z-50 animate-slide-up'
    toast.textContent = message

    document.body.appendChild(toast)

    // Remove after 3 seconds
    setTimeout(() => {
      toast.classList.add('opacity-0', 'transition-opacity', 'duration-300')
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }
}
