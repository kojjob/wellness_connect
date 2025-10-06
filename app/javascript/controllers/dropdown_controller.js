import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu", "button"]
  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    console.log("Dropdown controller connected", this.element)
    // Bind event handlers
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    this.boundHandleEscape = this.handleEscape.bind(this)

    // Initialize menu state
    if (this.hasMenuTarget) {
      this.menuTarget.style.opacity = "0"
      this.menuTarget.style.transform = "scale(0.95)"
      this.menuTarget.classList.add("hidden")
    }
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    console.log("Dropdown toggle clicked", this.openValue)

    if (this.openValue) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    console.log("Opening dropdown")

    // Close any other open dropdowns
    this.closeOtherDropdowns()

    this.openValue = true
    this.menuTarget.classList.remove("hidden", "hide")
    this.menuTarget.classList.add("block")
    this.buttonTarget.setAttribute("aria-expanded", "true")

    // Trigger animation with proper timing
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this.menuTarget.classList.add("show")
        this.menuTarget.style.opacity = "1"
        this.menuTarget.style.transform = "scale(1)"
      })
    })

    // Add event listeners after a small delay to prevent immediate closing
    setTimeout(() => {
      document.addEventListener("click", this.boundHandleClickOutside)
      document.addEventListener("keydown", this.boundHandleEscape)
    }, 10)
  }

  closeOtherDropdowns() {
    // Find all other dropdown controllers and close them
    const otherDropdowns = document.querySelectorAll('[data-controller*="dropdown"]')
    otherDropdowns.forEach(dropdown => {
      if (dropdown !== this.element) {
        const controller = this.application.getControllerForElementAndIdentifier(dropdown, "dropdown")
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

    // Trigger close animation
    this.menuTarget.classList.remove("show")
    this.menuTarget.classList.add("hide")
    this.menuTarget.style.opacity = "0"
    this.menuTarget.style.transform = "scale(0.95)"

    // Wait for animation to complete before hiding
    setTimeout(() => {
      if (!this.openValue) { // Double check we're still closed
        this.menuTarget.classList.add("hidden")
        this.menuTarget.classList.remove("block", "hide")
      }
    }, 200)

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
  }
}
