import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="faq"
export default class extends Controller {
  static targets = ["item", "content", "icon"]

  connect() {
    console.log("FAQ controller connected")
    // Close all items by default
    this.contentTargets.forEach(content => {
      content.style.maxHeight = '0'
      content.style.overflow = 'hidden'
      content.style.transition = 'max-height 0.3s ease-out'
    })
  }

  toggle(event) {
    const button = event.currentTarget
    const content = button.nextElementSibling
    const icon = button.querySelector('[data-faq-target="icon"]')
    const isOpen = content.style.maxHeight !== '0px' && content.style.maxHeight !== ''

    if (isOpen) {
      // Close this item
      content.style.maxHeight = '0'
      if (icon) {
        icon.style.transform = 'rotate(0deg)'
      }
    } else {
      // Close all other items first (accordion behavior)
      this.contentTargets.forEach((otherContent, index) => {
        if (otherContent !== content) {
          otherContent.style.maxHeight = '0'
          const otherIcon = this.iconTargets[index]
          if (otherIcon) {
            otherIcon.style.transform = 'rotate(0deg)'
          }
        }
      })

      // Open this item
      content.style.maxHeight = content.scrollHeight + 'px'
      if (icon) {
        icon.style.transform = 'rotate(180deg)'
      }
    }
  }
}

