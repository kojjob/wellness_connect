import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="patient-dashboard"
export default class extends Controller {
  connect() {
    this.initializeCountdowns()
    this.startCountdownUpdates()
  }

  disconnect() {
    if (this.countdownInterval) {
      clearInterval(this.countdownInterval)
    }
  }

  // Dismiss alert messages
  dismissAlert(event) {
    const alert = event.currentTarget.closest('[class*="bg-"]')
    if (alert) {
      alert.classList.add('opacity-0', 'transition-opacity', 'duration-300')
      setTimeout(() => alert.remove(), 300)
    }
  }

  // Initialize countdown timers for upcoming appointments
  initializeCountdowns() {
    const countdownElements = document.querySelectorAll('[data-countdown-time]')
    countdownElements.forEach(element => {
      const targetTime = new Date(element.dataset.countdownTime).getTime()
      this.updateCountdown(element, targetTime)
    })
  }

  // Start interval to update countdowns every minute
  startCountdownUpdates() {
    this.countdownInterval = setInterval(() => {
      this.initializeCountdowns()
    }, 60000) // Update every minute
  }

  // Update individual countdown display
  updateCountdown(element, targetTime) {
    const now = new Date().getTime()
    const distance = targetTime - now

    if (distance < 0) {
      element.textContent = "Starting soon..."
      return
    }

    const days = Math.floor(distance / (1000 * 60 * 60 * 24))
    const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60))

    if (days > 0) {
      element.textContent = `Starts in ${days}d ${hours}h`
    } else if (hours > 0) {
      element.textContent = `Starts in ${hours}h ${minutes}m`
    } else {
      element.textContent = `Starts in ${minutes}m`
    }
  }

  // Show toast notification
  showToast(message, type = 'info') {
    const toast = document.createElement('div')
    const bgColors = {
      success: 'bg-green-500',
      error: 'bg-red-500',
      warning: 'bg-yellow-500',
      info: 'bg-teal-500'
    }

    toast.className = `fixed bottom-4 right-4 ${bgColors[type] || bgColors.info} text-white px-6 py-3 rounded-lg shadow-lg z-50 animate-slide-up`
    toast.textContent = message

    document.body.appendChild(toast)

    // Remove after 3 seconds
    setTimeout(() => {
      toast.classList.add('opacity-0', 'transition-opacity', 'duration-300')
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }

  // Mark notification as read
  markNotificationRead(event) {
    event.preventDefault()
    const notificationId = event.currentTarget.dataset.notificationId
    
    // Here you would make an AJAX call to mark the notification as read
    // For now, just remove the unread indicator
    const unreadIndicator = event.currentTarget.querySelector('.bg-blue-500')
    if (unreadIndicator) {
      unreadIndicator.classList.add('opacity-0')
      setTimeout(() => unreadIndicator.remove(), 300)
    }

    this.showToast('Notification marked as read', 'success')
  }

  // Refresh dashboard data (for future implementation with Turbo Frames)
  refreshDashboard() {
    this.showToast('Refreshing dashboard...', 'info')
    // Implement Turbo Frame refresh here
    setTimeout(() => {
      this.showToast('Dashboard updated', 'success')
    }, 1000)
  }
}

