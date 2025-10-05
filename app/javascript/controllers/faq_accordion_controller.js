import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="faq-accordion"
export default class extends Controller {
  static targets = ["item", "content", "icon"]
  static values = {
    allowMultiple: { type: Boolean, default: false }
  }

  connect() {
    // Initialize all items as closed
    this.itemTargets.forEach((item, index) => {
      const content = this.contentTargets[index]
      const icon = this.iconTargets[index]
      
      if (content) {
        content.style.maxHeight = "0"
        content.style.overflow = "hidden"
        content.style.transition = "max-height 0.3s ease-out"
        content.setAttribute("aria-hidden", "true")
      }
      
      if (icon) {
        icon.style.transition = "transform 0.3s ease-out"
      }

      // Set initial ARIA attributes
      const button = item.querySelector("button")
      if (button) {
        button.setAttribute("aria-expanded", "false")
      }
    })
  }

  toggle(event) {
    const button = event.currentTarget
    const itemIndex = this.itemTargets.indexOf(button.closest("[data-faq-accordion-target='item']"))
    const content = this.contentTargets[itemIndex]
    const icon = this.iconTargets[itemIndex]
    const isOpen = button.getAttribute("aria-expanded") === "true"

    if (!this.allowMultipleValue && !isOpen) {
      // Close all other items
      this.closeAll()
    }

    if (isOpen) {
      this.closeItem(itemIndex)
    } else {
      this.openItem(itemIndex)
    }
  }

  openItem(index) {
    const item = this.itemTargets[index]
    const content = this.contentTargets[index]
    const icon = this.iconTargets[index]
    const button = item.querySelector("button")

    if (content) {
      // Set max-height to scrollHeight for smooth animation
      content.style.maxHeight = content.scrollHeight + "px"
      content.setAttribute("aria-hidden", "false")
    }

    if (icon) {
      icon.style.transform = "rotate(180deg)"
    }

    if (button) {
      button.setAttribute("aria-expanded", "true")
    }

    // Add open class for additional styling
    item.classList.add("faq-item-open")
  }

  closeItem(index) {
    const item = this.itemTargets[index]
    const content = this.contentTargets[index]
    const icon = this.iconTargets[index]
    const button = item.querySelector("button")

    if (content) {
      content.style.maxHeight = "0"
      content.setAttribute("aria-hidden", "true")
    }

    if (icon) {
      icon.style.transform = "rotate(0deg)"
    }

    if (button) {
      button.setAttribute("aria-expanded", "false")
    }

    // Remove open class
    item.classList.remove("faq-item-open")
  }

  closeAll() {
    this.itemTargets.forEach((item, index) => {
      this.closeItem(index)
    })
  }

  openAll() {
    this.itemTargets.forEach((item, index) => {
      this.openItem(index)
    })
  }
}

