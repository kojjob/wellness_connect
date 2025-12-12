import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="view-toggle"
export default class extends Controller {
  static targets = ["gridButton", "listButton", "gridView", "listView"]
  
  static values = {
    currentView: { type: String, default: "grid" }
  }

  connect() {
    // Load saved preference from localStorage
    const savedView = localStorage.getItem("providerViewPreference")
    if (savedView) {
      this.currentViewValue = savedView
    }
    this.updateView()
  }

  showGrid() {
    this.currentViewValue = "grid"
    localStorage.setItem("providerViewPreference", "grid")
    this.updateView()
  }

  showList() {
    this.currentViewValue = "list"
    localStorage.setItem("providerViewPreference", "list")
    this.updateView()
  }

  updateView() {
    if (this.currentViewValue === "grid") {
      // Show grid view
      this.gridViewTarget.classList.remove("hidden")
      this.listViewTarget.classList.add("hidden")
      
      // Update button states
      this.gridButtonTarget.classList.add("bg-indigo-600", "text-white")
      this.gridButtonTarget.classList.remove("bg-white", "text-gray-700", "border-gray-300")
      
      this.listButtonTarget.classList.remove("bg-indigo-600", "text-white")
      this.listButtonTarget.classList.add("bg-white", "text-gray-700", "border-gray-300")
    } else {
      // Show list view
      this.listViewTarget.classList.remove("hidden")
      this.gridViewTarget.classList.add("hidden")
      
      // Update button states
      this.listButtonTarget.classList.add("bg-indigo-600", "text-white")
      this.listButtonTarget.classList.remove("bg-white", "text-gray-700", "border-gray-300")
      
      this.gridButtonTarget.classList.remove("bg-indigo-600", "text-white")
      this.gridButtonTarget.classList.add("bg-white", "text-gray-700", "border-gray-300")
    }
  }
}

