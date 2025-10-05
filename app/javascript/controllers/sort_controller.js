import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sort"
export default class extends Controller {
  static targets = ["dropdown", "button", "selectedText"]
  
  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    console.log("Sort controller connected")
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleClickOutside)
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
    this.dropdownTarget.classList.remove("hidden")
    this.dropdownTarget.classList.add("block")
    
    // Add click outside listener
    setTimeout(() => {
      document.addEventListener("click", this.boundHandleClickOutside)
    }, 10)
  }

  close() {
    this.openValue = false
    this.dropdownTarget.classList.add("hidden")
    this.dropdownTarget.classList.remove("block")
    document.removeEventListener("click", this.boundHandleClickOutside)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  select(event) {
    event.preventDefault()
    const sortValue = event.currentTarget.dataset.sortValue
    const sortLabel = event.currentTarget.dataset.sortLabel
    
    // Update selected text
    if (this.hasSelectedTextTarget) {
      this.selectedTextTarget.textContent = sortLabel
    }
    
    // Update URL with sort parameter
    const url = new URL(window.location)
    url.searchParams.set('sort', sortValue)
    window.location.href = url.toString()
    
    this.close()
  }
}

