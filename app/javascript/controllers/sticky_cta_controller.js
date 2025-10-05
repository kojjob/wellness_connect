import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    threshold: { type: Number, default: 800 }
  }

  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener('scroll', this.handleScroll)
    this.handleScroll() // Check initial state
  }

  disconnect() {
    window.removeEventListener('scroll', this.handleScroll)
  }

  handleScroll() {
    if (window.scrollY > this.thresholdValue) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.element.classList.remove('translate-y-full')
    this.element.classList.add('translate-y-0')
  }

  hide() {
    this.element.classList.remove('translate-y-0')
    this.element.classList.add('translate-y-full')
  }

  close(event) {
    event.preventDefault()
    this.element.classList.add('translate-y-full')
    // Set cookie to remember user closed it
    document.cookie = "sticky_cta_closed=true; max-age=86400; path=/"
  }
}

