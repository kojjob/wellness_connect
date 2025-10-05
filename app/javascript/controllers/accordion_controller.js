import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="accordion"
export default class extends Controller {
  static targets = ["item", "button", "panel"]
  static values = {
    allowMultiple: { type: Boolean, default: false }
  }

  connect() {
    console.log("Accordion controller connected")
    
    // Set initial ARIA attributes
    this.buttonTargets.forEach((button, index) => {
      button.setAttribute('aria-expanded', 'false')
      button.setAttribute('aria-controls', `accordion-panel-${index}`)
      
      const panel = this.panelTargets[index]
      panel.setAttribute('id', `accordion-panel-${index}`)
      panel.setAttribute('aria-hidden', 'true')
      panel.classList.add('hidden')
    })
  }

  toggle(event) {
    event.preventDefault()
    const button = event.currentTarget
    const index = this.buttonTargets.indexOf(button)
    const panel = this.panelTargets[index]
    const isExpanded = button.getAttribute('aria-expanded') === 'true'
    
    if (!this.allowMultipleValue) {
      // Close all other panels
      this.buttonTargets.forEach((btn, idx) => {
        if (idx !== index) {
          this.closePanel(btn, this.panelTargets[idx])
        }
      })
    }
    
    if (isExpanded) {
      this.closePanel(button, panel)
    } else {
      this.openPanel(button, panel)
    }
  }

  openPanel(button, panel) {
    button.setAttribute('aria-expanded', 'true')
    panel.setAttribute('aria-hidden', 'false')
    panel.classList.remove('hidden')
    
    // Rotate icon
    const icon = button.querySelector('[data-accordion-icon]')
    if (icon) {
      icon.classList.add('rotate-180')
    }
    
    // Smooth height animation
    panel.style.maxHeight = panel.scrollHeight + 'px'
  }

  closePanel(button, panel) {
    button.setAttribute('aria-expanded', 'false')
    panel.setAttribute('aria-hidden', 'true')
    
    // Rotate icon back
    const icon = button.querySelector('[data-accordion-icon]')
    if (icon) {
      icon.classList.remove('rotate-180')
    }
    
    // Smooth height animation
    panel.style.maxHeight = '0'
    
    // Hide after animation completes
    setTimeout(() => {
      if (button.getAttribute('aria-expanded') === 'false') {
        panel.classList.add('hidden')
      }
    }, 300)
  }

  // Handle keyboard navigation
  handleKeydown(event) {
    const currentIndex = this.buttonTargets.findIndex(btn => btn === event.target)
    
    if (event.key === 'ArrowDown') {
      event.preventDefault()
      const nextIndex = (currentIndex + 1) % this.buttonTargets.length
      this.buttonTargets[nextIndex].focus()
    } else if (event.key === 'ArrowUp') {
      event.preventDefault()
      const prevIndex = (currentIndex - 1 + this.buttonTargets.length) % this.buttonTargets.length
      this.buttonTargets[prevIndex].focus()
    } else if (event.key === 'Home') {
      event.preventDefault()
      this.buttonTargets[0].focus()
    } else if (event.key === 'End') {
      event.preventDefault()
      this.buttonTargets[this.buttonTargets.length - 1].focus()
    }
  }
}

