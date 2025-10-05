import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="smooth-scroll"
export default class extends Controller {
  connect() {
    console.log("Smooth scroll controller connected")
  }

  scroll(event) {
    event.preventDefault()
    
    const targetId = event.currentTarget.getAttribute('href')
    const targetElement = document.querySelector(targetId)
    
    if (targetElement) {
      // Calculate offset for fixed navbar (if any)
      const navbarHeight = 80 // Adjust based on your navbar height
      const elementPosition = targetElement.getBoundingClientRect().top
      const offsetPosition = elementPosition + window.pageYOffset - navbarHeight
      
      window.scrollTo({
        top: offsetPosition,
        behavior: 'smooth'
      })
    }
  }
}

