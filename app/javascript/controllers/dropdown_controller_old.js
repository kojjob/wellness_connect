import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
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
    console.log("Opening dropdown - before changes")
    console.log("Menu classes before:", this.menuTarget.className)
    console.log("Menu style before:", this.menuTarget.style.cssText)

    // Close any other open dropdowns
    this.closeOtherDropdowns()

    this.openValue = true

    // Aggressively remove any hiding classes and add block
    this.menuTarget.classList.remove("hidden", "hide", "invisible")
    this.menuTarget.classList.add("block", "visible")
    this.buttonTarget.setAttribute("aria-expanded", "true")

    console.log("Classes after aggressive removal:", this.menuTarget.className)

    console.log("Menu classes after class changes:", this.menuTarget.className)

    // Remove ALL inline styles first to clear any conflicts
    this.menuTarget.removeAttribute("style")

    // Force immediate visibility with !important to override any CSS
    this.menuTarget.style.setProperty("display", "block", "important")
    this.menuTarget.style.setProperty("opacity", "1", "important")
    this.menuTarget.style.setProperty("transform", "none", "important")
    this.menuTarget.style.setProperty("visibility", "visible", "important")

    console.log("Menu classes after style changes:", this.menuTarget.className)
    console.log("Menu style after:", this.menuTarget.style.cssText)
    console.log("Menu computed style:", window.getComputedStyle(this.menuTarget).display)

    // Check positioning and visibility
    const rect = this.menuTarget.getBoundingClientRect()
    console.log("Menu position:", {
      top: rect.top,
      left: rect.left,
      width: rect.width,
      height: rect.height,
      bottom: rect.bottom,
      right: rect.right
    })

    const computedStyle = window.getComputedStyle(this.menuTarget)
    console.log("Menu computed styles:", {
      display: computedStyle.display,
      visibility: computedStyle.visibility,
      opacity: computedStyle.opacity,
      zIndex: computedStyle.zIndex,
      position: computedStyle.position,
      backgroundColor: computedStyle.backgroundColor
    })

    // Position dropdown relative to button for proper placement
    this.positionDropdown()

    console.log("Dropdown opened successfully")

    console.log("Dropdown styles applied")

    // Force positioning fix with proper timing
    requestAnimationFrame(() => {
      const rect = this.menuTarget.getBoundingClientRect()
      const viewportWidth = window.innerWidth

      console.log("Checking positioning:", {
        left: rect.left,
        right: rect.right,
        viewportWidth: viewportWidth,
        shouldFix: rect.right > viewportWidth || rect.left > viewportWidth - 100
      })

      // Always force to visible position for debugging
      console.log("FORCING dropdown to visible position for debugging")
      this.menuTarget.style.position = "fixed !important"
      this.menuTarget.style.top = "80px !important"
      this.menuTarget.style.right = "20px !important"
      this.menuTarget.style.left = "auto !important"
      this.menuTarget.style.transform = "none !important"
      this.menuTarget.style.margin = "0 !important"

      console.log("Dropdown should now be visible at top-right corner")

      // Debug the actual dropdown element
      console.log("=== DROPDOWN ELEMENT DEBUG ===")
      console.log("Element:", this.menuTarget)
      console.log("Parent:", this.menuTarget.parentElement)

      // Check specific computed style properties that affect visibility
      const computed = window.getComputedStyle(this.menuTarget)
      console.log("CRITICAL COMPUTED STYLES:")
      console.log("display:", computed.display)
      console.log("visibility:", computed.visibility)
      console.log("opacity:", computed.opacity)
      console.log("position:", computed.position)
      console.log("top:", computed.top)
      console.log("right:", computed.right)
      console.log("left:", computed.left)
      console.log("bottom:", computed.bottom)
      console.log("z-index:", computed.zIndex)
      console.log("width:", computed.width)
      console.log("height:", computed.height)
      console.log("background-color:", computed.backgroundColor)
      console.log("border:", computed.border)
      console.log("transform:", computed.transform)
      console.log("clip:", computed.clip)
      console.log("clip-path:", computed.clipPath)
      console.log("overflow:", computed.overflow)

      // Check parent element styles that might affect visibility
      const parentComputed = window.getComputedStyle(this.menuTarget.parentElement)
      console.log("PARENT ELEMENT STYLES:")
      console.log("parent overflow:", parentComputed.overflow)
      console.log("parent position:", parentComputed.position)
      console.log("parent z-index:", parentComputed.zIndex)

      // Force the dropdown to be visible with extreme measures
      this.menuTarget.style.setProperty("position", "fixed", "important")
      this.menuTarget.style.setProperty("top", "50px", "important")
      this.menuTarget.style.setProperty("left", "50px", "important")
      this.menuTarget.style.setProperty("right", "auto", "important")
      this.menuTarget.style.setProperty("bottom", "auto", "important")
      this.menuTarget.style.setProperty("width", "500px", "important")
      this.menuTarget.style.setProperty("height", "400px", "important")
      this.menuTarget.style.setProperty("background-color", "red", "important")
      this.menuTarget.style.setProperty("border", "10px solid blue", "important")
      this.menuTarget.style.setProperty("z-index", "999999", "important")
      this.menuTarget.style.setProperty("display", "block", "important")
      this.menuTarget.style.setProperty("visibility", "visible", "important")
      this.menuTarget.style.setProperty("opacity", "1", "important")
      this.menuTarget.style.setProperty("transform", "none", "important")
      this.menuTarget.style.setProperty("clip", "auto", "important")
      this.menuTarget.style.setProperty("clip-path", "none", "important")
      this.menuTarget.style.setProperty("overflow", "visible", "important")

      this.menuTarget.innerHTML = '<div style="color: white; font-size: 30px; padding: 50px; text-align: center; font-weight: bold; background: green;">🚨 EMERGENCY DROPDOWN 🚨<br>If you see this, CSS was the issue!</div>'

      console.log("Emergency dropdown applied - should be at top-left corner")

      // Check if element is actually in the DOM
      console.log("Is in DOM:", document.contains(this.menuTarget))
      console.log("Is connected:", this.menuTarget.isConnected)
    })

    // Add event listeners after a small delay to prevent immediate closing
    setTimeout(() => {
      document.addEventListener("click", this.boundHandleClickOutside)
      document.addEventListener("keydown", this.boundHandleEscape)
    }, 10)
  }

  positionDropdown() {
    if (!this.hasButtonTarget) return

    // Get button position
    const buttonRect = this.buttonTarget.getBoundingClientRect()
    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight

    // Reset positioning classes and styles
    this.menuTarget.classList.remove("right-0", "left-0")
    this.menuTarget.style.removeProperty("right")
    this.menuTarget.style.removeProperty("left")
    this.menuTarget.style.removeProperty("top")
    this.menuTarget.style.removeProperty("bottom")

    // Set position to absolute for proper positioning
    this.menuTarget.style.setProperty("position", "absolute", "important")
    this.menuTarget.style.setProperty("z-index", "9999", "important")

    // Calculate optimal position
    const dropdownWidth = 288 // w-72 = 288px
    const dropdownHeight = 400 // estimated height

    // Default: position below and to the right of button
    let top = buttonRect.height + 12 // mt-3 = 12px
    let right = 0

    // Check if dropdown would go off-screen to the right
    if (buttonRect.right - dropdownWidth < 0) {
      // Position to the left instead
      this.menuTarget.style.setProperty("left", "0", "important")
    } else {
      // Position to the right (default)
      this.menuTarget.style.setProperty("right", "0", "important")
    }

    // Check if dropdown would go off-screen at the bottom
    if (buttonRect.bottom + dropdownHeight > viewportHeight) {
      // Position above the button instead
      this.menuTarget.style.setProperty("bottom", "100%", "important")
      this.menuTarget.style.setProperty("margin-bottom", "12px", "important")
    } else {
      // Position below the button (default)
      this.menuTarget.style.setProperty("top", `${top}px`, "important")
    }

    console.log("Dropdown positioned relative to button:", {
      buttonRect,
      dropdownPosition: this.menuTarget.getBoundingClientRect()
    })
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

  close() {
    console.log("Closing dropdown")

    this.openValue = false
    this.buttonTarget.setAttribute("aria-expanded", "false")

    // Hide the dropdown
    this.menuTarget.style.setProperty("display", "none", "important")
    this.menuTarget.classList.add("hidden")
    this.menuTarget.classList.remove("block", "show", "hide", "visible")

    // Remove event listeners
    document.removeEventListener("click", this.boundHandleClickOutside)
    document.removeEventListener("keydown", this.boundHandleEscape)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
      this.buttonTarget.focus()
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
