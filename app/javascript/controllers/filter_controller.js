import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filter"
export default class extends Controller {
  static targets = [
    "form",
    "sidebar",
    "mobileToggle",
    "priceMin",
    "priceMax",
    "priceDisplay",
    "clearButton"
  ]

  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    this.updatePriceDisplay()
    this.checkClearButton()
  }

  toggleSidebar() {
    this.openValue = !this.openValue
    
    if (this.openValue) {
      this.sidebarTarget.classList.remove("hidden")
      this.sidebarTarget.classList.add("block")
      // Prevent body scroll on mobile
      document.body.style.overflow = "hidden"
    } else {
      this.sidebarTarget.classList.add("hidden")
      this.sidebarTarget.classList.remove("block")
      document.body.style.overflow = ""
    }
  }

  closeSidebar() {
    this.openValue = false
    this.sidebarTarget.classList.add("hidden")
    this.sidebarTarget.classList.remove("block")
    document.body.style.overflow = ""
  }

  updatePriceDisplay() {
    if (!this.hasPriceDisplayTarget) return

    const min = this.priceMinTarget.value || 0
    const max = this.priceMaxTarget.value || ""

    if (min && max) {
      this.priceDisplayTarget.textContent = `$${min} - $${max}`
    } else if (min && !max) {
      this.priceDisplayTarget.textContent = `$${min}+`
    } else if (!min && max) {
      this.priceDisplayTarget.textContent = `$0 - $${max}`
    } else {
      this.priceDisplayTarget.textContent = `$0 - $500+`
    }
  }

  clearFilters(event) {
    event.preventDefault()
    
    // Reset all form inputs
    const form = this.formTarget
    const inputs = form.querySelectorAll('input[type="text"], input[type="number"], select')
    
    inputs.forEach(input => {
      if (input.type === 'text' || input.type === 'number') {
        input.value = ''
      } else if (input.tagName === 'SELECT') {
        input.selectedIndex = 0
      }
    })

    // Reset checkboxes
    const checkboxes = form.querySelectorAll('input[type="checkbox"]')
    checkboxes.forEach(checkbox => {
      checkbox.checked = false
    })

    // Update price display
    this.updatePriceDisplay()

    // Submit form to show all results
    form.submit()
  }

  checkClearButton() {
    if (!this.hasClearButtonTarget) return

    const form = this.formTarget
    const inputs = form.querySelectorAll('input[type="text"], input[type="number"], select')
    let hasFilters = false

    inputs.forEach(input => {
      if (input.value && input.value !== '') {
        hasFilters = true
      }
    })

    const checkboxes = form.querySelectorAll('input[type="checkbox"]:checked')
    if (checkboxes.length > 0) {
      hasFilters = true
    }

    if (hasFilters) {
      this.clearButtonTarget.classList.remove("hidden")
    } else {
      this.clearButtonTarget.classList.add("hidden")
    }
  }

  submitForm() {
    this.formTarget.submit()
  }
}
