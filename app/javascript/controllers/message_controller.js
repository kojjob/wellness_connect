import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="message"
export default class extends Controller {
  connect() {
    console.log("Message controller connected")
  }

  send(event) {
    event.preventDefault()
    
    // Show "Coming Soon" toast notification
    this.showToast("Messaging feature coming soon! 💬", "info")
  }

  showToast(message, type = "info") {
    // Create toast notification
    const toast = document.createElement('div')
    
    let bgColor = 'bg-blue-500'
    if (type === 'success') bgColor = 'bg-green-500'
    if (type === 'error') bgColor = 'bg-red-500'
    if (type === 'warning') bgColor = 'bg-yellow-500'
    
    toast.className = `fixed bottom-6 left-1/2 transform -translate-x-1/2 px-6 py-3 rounded-lg shadow-lg text-white font-medium z-50 transition-all duration-300 ${bgColor}`
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

