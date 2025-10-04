import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="smooth-scroll"
export default class extends Controller {
  connect() {
    console.log("Smooth scroll controller connected")
  }

  scroll(event) {
    event.preventDefault()
    const targetId = event.currentTarget.getAttribute("href")
    const targetElement = document.querySelector(targetId)
    
    if (targetElement) {
      const offset = 80 // Account for fixed navbar
      const targetPosition = targetElement.getBoundingClientRect().top + window.pageYOffset - offset
      
      window.scrollTo({
        top: targetPosition,
        behavior: "smooth"
      })
    }
  }
}

