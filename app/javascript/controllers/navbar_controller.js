import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = ["mobileMenu", "mobileMenuButton", "mobileMenuIcon", "mobileMenuCloseIcon"]

  connect() {
    // Close mobile menu on window resize to desktop
    this.boundHandleResize = this.handleResize.bind(this)
    window.addEventListener("resize", this.boundHandleResize)
  }

  disconnect() {
    window.removeEventListener("resize", this.boundHandleResize)
  }

  toggleMobileMenu() {
    const isOpen = !this.mobileMenuTarget.classList.contains("hidden")


    if (isOpen) {
      this.closeMobileMenu()
    } else {
      this.openMobileMenu()
    }
  }

  openMobileMenu() {
    this.mobileMenuTarget.classList.remove("hidden")
    this.mobileMenuIconTarget.classList.add("hidden")
    this.mobileMenuCloseIconTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    
    // Set ARIA attributes
    this.mobileMenuButtonTarget.setAttribute("aria-expanded", "true")
  }

  closeMobileMenu() {
    this.mobileMenuTarget.classList.add("hidden")
    this.mobileMenuIconTarget.classList.remove("hidden")
    this.mobileMenuCloseIconTarget.classList.add("hidden")
    document.body.style.overflow = ""
    
    // Set ARIA attributes
    this.mobileMenuButtonTarget.setAttribute("aria-expanded", "false")
  }

  handleResize() {
    // Close mobile menu if window is resized to desktop size
    if (window.innerWidth >= 768) {
      this.closeMobileMenu()
    }
  }

  // Close mobile menu when clicking a link
  handleLinkClick() {
    this.closeMobileMenu()
  }
}
