import { Controller } from "@hotwired/stimulus"

// Clean dropdown controller with proper positioning
export default class extends Controller {
  static targets = ["menu", "button"]
  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    // Store reference to controller on element for easy access
    this.element.dropdownController = this
    
    // Bind event handlers
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    this.boundHandleEscape = this.handleEscape.bind(this)

    // Initialize menu state
    if (this.hasMenuTarget) {
      this.menuTarget.classList.add("hidden")
      this.menuTarget.style.opacity = "0"
      this.menuTarget.style.transform = "scale(0.95)"
    }
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (!this.hasMenuTarget) {
      return
    }

    if (this.openValue) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    // Close any other open dropdowns
    this.closeOtherDropdowns()
    
    this.openValue = true
    
    // Remove hidden class and show dropdown
    this.menuTarget.classList.remove("hidden")
    this.menuTarget.classList.add("block")
    
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "true")
    }

    // Position dropdown properly with fixed positioning to avoid CSS conflicts
    this.positionDropdownCorrectly()

    // Add smooth animation
    requestAnimationFrame(() => {
      this.menuTarget.style.opacity = "1"
      this.menuTarget.style.transform = "scale(1)"
    })

    // Add event listeners after a small delay to prevent immediate closing
    setTimeout(() => {
      document.addEventListener("click", this.boundHandleClickOutside)
      document.addEventListener("keydown", this.boundHandleEscape)
    }, 10)
  }

  close() {
    this.openValue = false
    
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }

    // Hide the dropdown with animation
    this.menuTarget.style.opacity = "0"
    this.menuTarget.style.transform = "scale(0.95)"

    // Wait for animation to complete before hiding
    setTimeout(() => {
      if (!this.openValue) { // Double check we're still closed
        this.menuTarget.classList.add("hidden")
        this.menuTarget.classList.remove("block")
      }
    }, 200)

    // Remove event listeners
    document.removeEventListener("click", this.boundHandleClickOutside)
    document.removeEventListener("keydown", this.boundHandleEscape)
  }

  positionDropdownCorrectly() {
    if (!this.hasButtonTarget) return
    
    // Get button position
    const buttonRect = this.buttonTarget.getBoundingClientRect()
    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight
    
    // Use fixed positioning to avoid CSS conflicts
    this.menuTarget.style.setProperty("position", "fixed", "important")
    this.menuTarget.style.setProperty("z-index", "9999", "important")
    this.menuTarget.style.setProperty("display", "block", "important")
    this.menuTarget.style.setProperty("visibility", "visible", "important")
    
    // Calculate optimal position
    const dropdownWidth = 288 // w-72 = 288px (or w-96 = 384px for notifications)
    const dropdownHeight = 400 // estimated height
    
    // Position below the button by default
    let top = buttonRect.bottom + 8 // 8px gap
    let left = buttonRect.right - dropdownWidth // align right edge with button right edge
    
    // Check if dropdown would go off-screen to the left
    if (left < 20) {
      left = 20 // 20px from left edge
    }
    
    // Check if dropdown would go off-screen to the right
    if (left + dropdownWidth > viewportWidth - 20) {
      left = viewportWidth - dropdownWidth - 20 // 20px from right edge
    }
    
    // Check if dropdown would go off-screen at the bottom
    if (top + dropdownHeight > viewportHeight - 20) {
      // Position above the button instead
      top = buttonRect.top - dropdownHeight - 8 // 8px gap above
      
      // If still off-screen at top, position at top of viewport
      if (top < 20) {
        top = 20
      }
    }
    
    // Apply the calculated position
    this.menuTarget.style.setProperty("top", `${top}px`, "important")
    this.menuTarget.style.setProperty("left", `${left}px`, "important")
    this.menuTarget.style.setProperty("right", "auto", "important")
    this.menuTarget.style.setProperty("bottom", "auto", "important")
    this.menuTarget.style.setProperty("transform", "none", "important")
    this.menuTarget.style.setProperty("margin", "0", "important")
  }

  closeOtherDropdowns() {
    // Find all other dropdown controllers and close them
    const otherDropdowns = document.querySelectorAll('[data-controller*="dropdown"]')
    otherDropdowns.forEach(dropdown => {
      if (dropdown !== this.element && dropdown.dropdownController) {
        const controller = dropdown.dropdownController
        if (controller && controller.openValue) {
          controller.close()
        }
      }
    })
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener("click", this.boundHandleClickOutside)
    document.removeEventListener("keydown", this.boundHandleEscape)
    
    // Remove controller reference
    if (this.element.dropdownController === this) {
      delete this.element.dropdownController
    }
  }
}
