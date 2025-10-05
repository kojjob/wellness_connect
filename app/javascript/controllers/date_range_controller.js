import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="date-range"
export default class extends Controller {
  static targets = ["startDate", "endDate", "form", "preset"]
  static values = {
    autoSubmit: { type: Boolean, default: true }
  }

  connect() {
    this.setDefaultDates()
  }

  setDefaultDates() {
    // Set default to last 30 days if no dates are set
    if (!this.startDateTarget.value) {
      const endDate = new Date()
      const startDate = new Date()
      startDate.setDate(startDate.getDate() - 30)

      this.startDateTarget.value = this.formatDate(startDate)
      this.endDateTarget.value = this.formatDate(endDate)
    }
  }

  formatDate(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  // Preset date range options
  applyPreset(event) {
    event.preventDefault()
    const preset = event.currentTarget.dataset.preset

    const endDate = new Date()
    const startDate = new Date()

    switch (preset) {
      case 'today':
        // Start and end are today
        break
      case 'yesterday':
        startDate.setDate(startDate.getDate() - 1)
        endDate.setDate(endDate.getDate() - 1)
        break
      case 'last_7_days':
        startDate.setDate(startDate.getDate() - 7)
        break
      case 'last_30_days':
        startDate.setDate(startDate.getDate() - 30)
        break
      case 'last_90_days':
        startDate.setDate(startDate.getDate() - 90)
        break
      case 'this_month':
        startDate.setDate(1) // First day of current month
        break
      case 'last_month':
        startDate.setMonth(startDate.getMonth() - 1)
        startDate.setDate(1)
        endDate.setMonth(endDate.getMonth() - 1)
        endDate.setDate(new Date(endDate.getFullYear(), endDate.getMonth() + 1, 0).getDate())
        break
      case 'this_quarter':
        const currentQuarter = Math.floor(startDate.getMonth() / 3)
        startDate.setMonth(currentQuarter * 3)
        startDate.setDate(1)
        break
      case 'this_year':
        startDate.setMonth(0)
        startDate.setDate(1)
        break
      case 'all_time':
        // Set start date to a very early date (e.g., 5 years ago)
        startDate.setFullYear(startDate.getFullYear() - 5)
        break
    }

    this.startDateTarget.value = this.formatDate(startDate)
    this.endDateTarget.value = this.formatDate(endDate)

    // Update active state on preset buttons
    this.updateActivePreset(event.currentTarget)

    // Auto-submit form if enabled
    if (this.autoSubmitValue) {
      this.submitForm()
    }
  }

  updateActivePreset(activeButton) {
    // Remove active class from all preset buttons
    this.presetTargets.forEach(btn => {
      btn.classList.remove('bg-teal-600', 'text-white')
      btn.classList.add('bg-gray-100', 'text-gray-700')
    })

    // Add active class to clicked button
    activeButton.classList.remove('bg-gray-100', 'text-gray-700')
    activeButton.classList.add('bg-teal-600', 'text-white')
  }

  // Manual date change handler
  dateChanged() {
    // Remove active state from all presets when custom dates are selected
    this.presetTargets.forEach(btn => {
      btn.classList.remove('bg-teal-600', 'text-white')
      btn.classList.add('bg-gray-100', 'text-gray-700')
    })

    // Validate date range
    if (this.startDateTarget.value && this.endDateTarget.value) {
      const start = new Date(this.startDateTarget.value)
      const end = new Date(this.endDateTarget.value)

      if (start > end) {
        this.showError("Start date must be before end date")
        return
      }

      // Auto-submit if enabled
      if (this.autoSubmitValue) {
        this.submitForm()
      }
    }
  }

  submitForm(event) {
    if (event) {
      event.preventDefault()
    }

    // Validate dates before submitting
    if (!this.startDateTarget.value || !this.endDateTarget.value) {
      this.showError("Please select both start and end dates")
      return
    }

    const start = new Date(this.startDateTarget.value)
    const end = new Date(this.endDateTarget.value)

    if (start > end) {
      this.showError("Start date must be before end date")
      return
    }

    // Submit the form
    if (this.hasFormTarget) {
      this.formTarget.requestSubmit()
    }
  }

  clearDates(event) {
    if (event) {
      event.preventDefault()
    }

    this.startDateTarget.value = ''
    this.endDateTarget.value = ''

    // Remove active state from presets
    this.presetTargets.forEach(btn => {
      btn.classList.remove('bg-teal-600', 'text-white')
      btn.classList.add('bg-gray-100', 'text-gray-700')
    })

    // Auto-submit to show all-time data
    if (this.autoSubmitValue) {
      this.submitForm()
    }
  }

  showError(message) {
    // Simple error display - can be enhanced with toast notifications
    alert(message)
  }

  // Helper method to get selected date range
  getDateRange() {
    return {
      start_date: this.startDateTarget.value,
      end_date: this.endDateTarget.value
    }
  }

  // Helper method to check if dates are selected
  hasDatesSelected() {
    return this.startDateTarget.value && this.endDateTarget.value
  }
}
