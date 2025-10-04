import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu", "button"]
  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    console.log("Dropdown controller connected")
    // Close dropdown when clicking outside
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    this.boundHandleEscape = this.handleEscape.bind(this)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (this.openValue) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.openValue = true
    this.menuTarget.classList.remove("hidden")
    this.menuTarget.classList.add("block")
    this.buttonTarget.setAttribute("aria-expanded", "true")
    
    // Add event listeners
    document.addEventListener("click", this.boundHandleClickOutside)
    document.addEventListener("keydown", this.boundHandleEscape)
  }

  close() {
    this.openValue = false
    this.menuTarget.classList.add("hidden")
    this.menuTarget.classList.remove("block")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    
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
    document.removeEventListener("click", this.boundHandleClickOutside)
    document.removeEventListener("keydown", this.boundHandleEscape)
  }
}

