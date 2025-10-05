import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    threshold: { type: Number, default: 800 }
  }

  connect() {
    // Check if user has dismissed the bar
    if (this.getCookie("sticky_cta_dismissed")) {
      this.element.classList.add("hidden")
      return
    }

    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener('scroll', this.handleScroll)
    this.handleScroll() // Check initial state
  }

  disconnect() {
    window.removeEventListener('scroll', this.handleScroll)
  }

  handleScroll() {
    if (this.getCookie("sticky_cta_dismissed")) {
      return
    }

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
    // Set cookie to remember user closed it (24 hours)
    this.setCookie("sticky_cta_dismissed", "true", 1)
  }

  getCookie(name) {
    const value = `; ${document.cookie}`
    const parts = value.split(`; ${name}=`)
    if (parts.length === 2) return parts.pop().split(';').shift()
    return null
  }

  setCookie(name, value, days) {
    const expires = new Date()
    expires.setTime(expires.getTime() + (days * 24 * 60 * 60 * 1000))
    document.cookie = `${name}=${value};expires=${expires.toUTCString()};path=/`
  }
}

