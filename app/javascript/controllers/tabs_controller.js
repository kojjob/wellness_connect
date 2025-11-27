import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = {
    defaultTab: String
  }

  connect() {
    
    // Show default tab or first tab
    const defaultTabId = this.defaultTabValue || this.tabTargets[0]?.dataset.tabId
    if (defaultTabId) {
      this.showTab(defaultTabId)
    }
    
    // Handle URL hash navigation
    if (window.location.hash) {
      const hashTabId = window.location.hash.substring(1)
      const matchingTab = this.tabTargets.find(tab => tab.dataset.tabId === hashTabId)
      if (matchingTab) {
        this.showTab(hashTabId)
      }
    }
  }

  selectTab(event) {
    event.preventDefault()
    const tabId = event.currentTarget.dataset.tabId
    this.showTab(tabId)
    
    // Update URL hash without scrolling
    history.pushState(null, null, `#${tabId}`)
  }

  showTab(tabId) {
    // Update tab buttons
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tabId === tabId) {
        // Active tab styles
        tab.classList.remove('text-gray-600', 'border-transparent', 'hover:text-gray-800', 'hover:border-gray-300')
        tab.classList.add('text-indigo-600', 'border-indigo-600', 'font-semibold')
        tab.setAttribute('aria-selected', 'true')
      } else {
        // Inactive tab styles
        tab.classList.remove('text-indigo-600', 'border-indigo-600', 'font-semibold')
        tab.classList.add('text-gray-600', 'border-transparent', 'hover:text-gray-800', 'hover:border-gray-300')
        tab.setAttribute('aria-selected', 'false')
      }
    })
    
    // Update panels
    this.panelTargets.forEach(panel => {
      if (panel.dataset.tabId === tabId) {
        panel.classList.remove('hidden')
        panel.setAttribute('aria-hidden', 'false')
      } else {
        panel.classList.add('hidden')
        panel.setAttribute('aria-hidden', 'true')
      }
    })
  }

  // Handle keyboard navigation
  handleKeydown(event) {
    const currentIndex = this.tabTargets.findIndex(tab => tab === event.target)
    
    if (event.key === 'ArrowRight') {
      event.preventDefault()
      const nextIndex = (currentIndex + 1) % this.tabTargets.length
      this.tabTargets[nextIndex].focus()
      this.showTab(this.tabTargets[nextIndex].dataset.tabId)
    } else if (event.key === 'ArrowLeft') {
      event.preventDefault()
      const prevIndex = (currentIndex - 1 + this.tabTargets.length) % this.tabTargets.length
      this.tabTargets[prevIndex].focus()
      this.showTab(this.tabTargets[prevIndex].dataset.tabId)
    } else if (event.key === 'Home') {
      event.preventDefault()
      this.tabTargets[0].focus()
      this.showTab(this.tabTargets[0].dataset.tabId)
    } else if (event.key === 'End') {
      event.preventDefault()
      const lastIndex = this.tabTargets.length - 1
      this.tabTargets[lastIndex].focus()
      this.showTab(this.tabTargets[lastIndex].dataset.tabId)
    }
  }
}

