import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="admin-users"
export default class extends Controller {
  static targets = [
    "searchInput",
    "form",
    "selectAll",
    "userCheckbox",
    "bulkActions",
    "selectedCount",
    "gridView",
    "tableView",
    "gridButton",
    "tableButton"
  ]

  static values = {
    currentView: { type: String, default: "table" },
    debounceTimer: Number
  }

  connect() {
    console.log("Admin users controller connected")
    // Load saved view preference
    const savedView = localStorage.getItem("adminUsersViewPreference")
    if (savedView) {
      this.currentViewValue = savedView
    }
    this.updateView()
    this.updateBulkActions()
  }

  // Search with debounce
  search() {
    clearTimeout(this.debounceTimerValue)
    this.debounceTimerValue = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, 300)
  }

  // Clear search and filters
  clearFilters(event) {
    event.preventDefault()
    
    // Reset all form inputs
    const form = this.formTarget
    const inputs = form.querySelectorAll('input[type="text"], input[type="date"], select')
    
    inputs.forEach(input => {
      if (input.type === 'text' || input.type === 'date') {
        input.value = ''
      } else if (input.tagName === 'SELECT') {
        input.selectedIndex = 0
      }
    })

    // Submit form to show all results
    form.requestSubmit()
  }

  // Toggle select all checkboxes
  toggleSelectAll() {
    const isChecked = this.selectAllTarget.checked
    this.userCheckboxTargets.forEach(checkbox => {
      checkbox.checked = isChecked
    })
    this.updateBulkActions()
  }

  // Update bulk actions visibility
  updateBulkActions() {
    const selectedCount = this.userCheckboxTargets.filter(cb => cb.checked).length
    
    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = selectedCount
    }

    if (this.hasBulkActionsTarget) {
      if (selectedCount > 0) {
        this.bulkActionsTarget.classList.remove("hidden")
      } else {
        this.bulkActionsTarget.classList.add("hidden")
      }
    }

    // Update select all checkbox state
    if (this.hasSelectAllTarget) {
      const allChecked = this.userCheckboxTargets.length > 0 && 
                        this.userCheckboxTargets.every(cb => cb.checked)
      const someChecked = this.userCheckboxTargets.some(cb => cb.checked)
      
      this.selectAllTarget.checked = allChecked
      this.selectAllTarget.indeterminate = someChecked && !allChecked
    }
  }

  // Export selected users to CSV
  exportSelected(event) {
    event.preventDefault()
    const selectedIds = this.userCheckboxTargets
      .filter(cb => cb.checked)
      .map(cb => cb.value)
    
    if (selectedIds.length === 0) {
      alert("Please select at least one user to export")
      return
    }

    // Create a form and submit it
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = '/admin/users/export'
    
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    const csrfInput = document.createElement('input')
    csrfInput.type = 'hidden'
    csrfInput.name = 'authenticity_token'
    csrfInput.value = csrfToken
    form.appendChild(csrfInput)
    
    selectedIds.forEach(id => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'user_ids[]'
      input.value = id
      form.appendChild(input)
    })
    
    document.body.appendChild(form)
    form.submit()
    document.body.removeChild(form)
  }

  // Toggle between grid and table view
  showGrid() {
    this.currentViewValue = "grid"
    localStorage.setItem("adminUsersViewPreference", "grid")
    this.updateView()
  }

  showTable() {
    this.currentViewValue = "table"
    localStorage.setItem("adminUsersViewPreference", "table")
    this.updateView()
  }

  updateView() {
    if (!this.hasGridViewTarget || !this.hasTableViewTarget) return

    if (this.currentViewValue === "grid") {
      // Show grid view
      this.gridViewTarget.classList.remove("hidden")
      this.tableViewTarget.classList.add("hidden")
      
      // Update button states
      this.gridButtonTarget.classList.add("bg-teal-600", "text-white")
      this.gridButtonTarget.classList.remove("bg-white", "text-gray-700", "border-gray-300")
      
      this.tableButtonTarget.classList.remove("bg-teal-600", "text-white")
      this.tableButtonTarget.classList.add("bg-white", "text-gray-700", "border-gray-300")
    } else {
      // Show table view
      this.tableViewTarget.classList.remove("hidden")
      this.gridViewTarget.classList.add("hidden")
      
      // Update button states
      this.tableButtonTarget.classList.add("bg-teal-600", "text-white")
      this.tableButtonTarget.classList.remove("bg-white", "text-gray-700", "border-gray-300")
      
      this.gridButtonTarget.classList.remove("bg-teal-600", "text-white")
      this.gridButtonTarget.classList.add("bg-white", "text-gray-700", "border-gray-300")
    }
  }

  // Sort table
  sort(event) {
    event.preventDefault()
    const column = event.currentTarget.dataset.column
    const currentSort = new URLSearchParams(window.location.search).get('sort')
    const currentDirection = new URLSearchParams(window.location.search).get('direction') || 'desc'
    
    let newDirection = 'asc'
    if (currentSort === column && currentDirection === 'asc') {
      newDirection = 'desc'
    }
    
    // Update form with sort parameters
    const sortInput = this.formTarget.querySelector('input[name="sort"]') || this.createHiddenInput('sort')
    const directionInput = this.formTarget.querySelector('input[name="direction"]') || this.createHiddenInput('direction')
    
    sortInput.value = column
    directionInput.value = newDirection
    
    this.formTarget.requestSubmit()
  }

  createHiddenInput(name) {
    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = name
    this.formTarget.appendChild(input)
    return input
  }

  // Confirm destructive action
  confirmAction(event) {
    const message = event.currentTarget.dataset.confirmMessage || "Are you sure?"
    if (!confirm(message)) {
      event.preventDefault()
      event.stopPropagation()
    }
  }
}

