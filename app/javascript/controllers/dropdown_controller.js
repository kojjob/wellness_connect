import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu", "button"]
  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    console.log("=== DROPDOWN CONTROLLER CONNECTING ===")
    console.log("Element:", this.element)
    console.log("Element HTML:", this.element.outerHTML.substring(0, 200))
    console.log("Has menu target:", this.hasMenuTarget)
    console.log("Has button target:", this.hasButtonTarget)

    if (this.hasMenuTarget) {
      console.log("Menu target found:", this.menuTarget)
      console.log("Menu target HTML:", this.menuTarget.outerHTML.substring(0, 200))
    } else {
      console.error("❌ NO MENU TARGET FOUND!")
      console.log("Looking for elements with data-dropdown-target='menu':")
      const menuElements = this.element.querySelectorAll('[data-dropdown-target="menu"]')
      console.log("Found menu elements:", menuElements)
    }

    if (this.hasButtonTarget) {
      console.log("Button target found:", this.buttonTarget)
    } else {
      console.error("❌ NO BUTTON TARGET FOUND!")
      console.log("Looking for elements with data-dropdown-target='button':")
      const buttonElements = this.element.querySelectorAll('[data-dropdown-target="button"]')
      console.log("Found button elements:", buttonElements)
    }

    // Store reference to controller on element for easy access
    this.element.dropdownController = this

    // Bind event handlers
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    this.boundHandleEscape = this.handleEscape.bind(this)

    // Initialize menu state
    if (this.hasMenuTarget) {
      this.menuTarget.style.opacity = "0"
      this.menuTarget.style.transform = "scale(0.95)"
      this.menuTarget.classList.add("hidden")
      console.log("✅ Menu initialized as hidden")
    }
  }

  toggle(event) {
    console.log("🔥 TOGGLE METHOD CALLED! 🔥")
    console.log("Event:", event)
    console.log("Event target:", event.target)
    console.log("Current element:", this.element)

    event.preventDefault()
    event.stopPropagation()

    console.log("Dropdown toggle clicked, current state:", this.openValue)
    console.log("Has targets:", { menu: this.hasMenuTarget, button: this.hasButtonTarget })

    if (!this.hasMenuTarget) {
      console.error("❌ NO MENU TARGET - Cannot open dropdown")
      return
    }

    if (!this.hasButtonTarget) {
      console.error("❌ NO BUTTON TARGET - But continuing anyway")
    }

    if (this.openValue) {
      console.log("🔽 Closing dropdown")
      this.close()
    } else {
      console.log("🔼 Opening dropdown")
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

    // Apply the same successful approach as the cloned dropdown
    this.menuTarget.style.setProperty("position", "fixed", "important")
    this.menuTarget.style.setProperty("top", "70px", "important")
    this.menuTarget.style.setProperty("right", "20px", "important")
    this.menuTarget.style.setProperty("left", "auto", "important")
    this.menuTarget.style.setProperty("z-index", "9999", "important")
    this.menuTarget.style.setProperty("transform", "none", "important")
    this.menuTarget.style.setProperty("margin", "0", "important")

    // Add very visible styling for debugging
    this.menuTarget.style.setProperty("background-color", "red", "important")
    this.menuTarget.style.setProperty("border", "10px solid blue", "important")
    this.menuTarget.style.setProperty("width", "300px", "important")
    this.menuTarget.style.setProperty("height", "200px", "important")

    // Add text content to make it obvious
    this.menuTarget.innerHTML = '<div style="color: white; font-size: 20px; padding: 20px;">DROPDOWN IS WORKING!</div>'

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
      console.log("All computed styles:", window.getComputedStyle(this.menuTarget))
      console.log("Element HTML:", this.menuTarget.outerHTML.substring(0, 200) + "...")

      // Check if element is actually in the DOM
      console.log("Is in DOM:", document.contains(this.menuTarget))
      console.log("Is connected:", this.menuTarget.isConnected)

      console.log("Dropdown positioning applied successfully")
    })

    // Add event listeners after a small delay to prevent immediate closing
    setTimeout(() => {
      document.addEventListener("click", this.boundHandleClickOutside)
      document.addEventListener("keydown", this.boundHandleEscape)
    }, 10)
  }

  adjustDropdownPosition() {
    const rect = this.menuTarget.getBoundingClientRect()
    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight

    console.log("Viewport dimensions:", { width: viewportWidth, height: viewportHeight })
    console.log("Dropdown rect before adjustment:", rect)

    // Check if dropdown is off-screen to the right
    if (rect.right > viewportWidth) {
      console.log("Dropdown is off-screen to the right, adjusting...")
      // Remove right-0 and add left positioning
      this.menuTarget.classList.remove("right-0")
      this.menuTarget.classList.add("left-0")
      this.menuTarget.style.right = "auto"
      this.menuTarget.style.left = "0"
    }

    // Check if dropdown is off-screen to the left
    if (rect.left < 0) {
      console.log("Dropdown is off-screen to the left, adjusting...")
      this.menuTarget.classList.remove("left-0")
      this.menuTarget.classList.add("right-0")
      this.menuTarget.style.left = "auto"
      this.menuTarget.style.right = "0"
    }

    // Check if dropdown is off-screen at the bottom
    if (rect.bottom > viewportHeight) {
      console.log("Dropdown is off-screen at bottom, adjusting...")
      this.menuTarget.style.top = "auto"
      this.menuTarget.style.bottom = "100%"
      this.menuTarget.style.marginBottom = "0.75rem"
      this.menuTarget.style.marginTop = "0"
    }

    const newRect = this.menuTarget.getBoundingClientRect()
    console.log("Dropdown rect after adjustment:", newRect)
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
