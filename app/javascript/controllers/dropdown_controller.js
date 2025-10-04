import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close dropdown when clicking outside
    this.boundCloseOnClickOutside = this.closeOnClickOutside.bind(this)
    document.addEventListener("click", this.boundCloseOnClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundCloseOnClickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
    
    // Update aria-expanded attribute
    const button = event.currentTarget
    const isExpanded = !this.menuTarget.classList.contains("hidden")
    button.setAttribute("aria-expanded", isExpanded)
  }

  close() {
    this.menuTarget.classList.add("hidden")
    
    // Update aria-expanded on all buttons in this controller
    const buttons = this.element.querySelectorAll('[aria-expanded]')
    buttons.forEach(button => button.setAttribute("aria-expanded", "false"))
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}

