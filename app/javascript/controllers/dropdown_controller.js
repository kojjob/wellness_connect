import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu", "button"]
  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    console.log("Dropdown controller connected", this.element)
    console.log("Has menu target:", this.hasMenuTarget)
    console.log("Has button target:", this.hasButtonTarget)
    console.log("Menu target:", this.hasMenuTarget ? this.menuTarget : "none")
    console.log("Button target:", this.hasButtonTarget ? this.buttonTarget : "none")

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
      console.log("Menu initialized as hidden")
    } else {
      console.error("No menu target found!")
    }

    if (!this.hasButtonTarget) {
      console.error("No button target found!")
    }
  }

  toggle(event) {
    console.log("Toggle method called", event)
    event.preventDefault()
    event.stopPropagation()

    console.log("Dropdown toggle clicked, current state:", this.openValue)
    console.log("Has targets:", { menu: this.hasMenuTarget, button: this.hasButtonTarget })

    if (!this.hasMenuTarget || !this.hasButtonTarget) {
      console.error("Missing required targets for dropdown")
      return
    }

    if (this.openValue) {
      console.log("Closing dropdown")
      this.close()
    } else {
      console.log("Opening dropdown")
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

    // Remove hidden class and add block
    this.menuTarget.classList.remove("hidden", "hide")
    this.menuTarget.classList.add("block")
    this.buttonTarget.setAttribute("aria-expanded", "true")

    console.log("Menu classes after class changes:", this.menuTarget.className)

    // Force immediate visibility for debugging
    this.menuTarget.style.display = "block"
    this.menuTarget.style.opacity = "1"
    this.menuTarget.style.transform = "scale(1)"

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

    // Quick fix: Force dropdown to appear in viewport
    const rect = this.menuTarget.getBoundingClientRect()
    const viewportWidth = window.innerWidth

    if (rect.right > viewportWidth || rect.left > viewportWidth - 100) {
      console.log("Forcing dropdown to visible position")
      this.menuTarget.style.position = "fixed"
      this.menuTarget.style.top = "60px"
      this.menuTarget.style.right = "20px"
      this.menuTarget.style.left = "auto"
    }

    // Add a temporary red border for visual debugging
    this.menuTarget.style.border = "3px solid red"
    this.menuTarget.style.backgroundColor = "yellow"

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
    console.log("Closing dropdown - before changes")
    console.log("Menu classes before:", this.menuTarget.className)

    this.openValue = false
    this.buttonTarget.setAttribute("aria-expanded", "false")

    // Immediate hide for debugging
    this.menuTarget.style.display = "none"
    this.menuTarget.style.opacity = "0"
    this.menuTarget.style.transform = "scale(0.95)"
    this.menuTarget.classList.add("hidden")
    this.menuTarget.classList.remove("block", "show", "hide")

    console.log("Menu classes after:", this.menuTarget.className)

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
