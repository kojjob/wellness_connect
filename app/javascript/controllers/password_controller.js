import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="password"
export default class extends Controller {
  static targets = ["input", "toggle", "strength", "strengthBar", "strengthText"]

  connect() {
    if (this.hasStrengthTarget) {
      this.checkStrength()
    }
  }

  toggle() {
    const input = this.inputTarget
    const type = input.getAttribute("type") === "password" ? "text" : "password"
    input.setAttribute("type", type)
    
    // Update icon
    const icon = this.toggleTarget.querySelector("svg")
    if (type === "password") {
      icon.innerHTML = '<path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path><path fill-rule="evenodd" d="M1.323 11.447C2.811 6.976 7.028 3.75 12.001 3.75c4.97 0 9.185 3.223 10.675 7.69.12.362.12.752 0 1.113-1.487 4.471-5.705 7.697-10.677 7.697-4.97 0-9.186-3.223-10.675-7.69a1.762 1.762 0 010-1.113zM17.25 12a5.25 5.25 0 11-10.5 0 5.25 5.25 0 0110.5 0z" clip-rule="evenodd"></path>'
    } else {
      icon.innerHTML = '<path fill-rule="evenodd" d="M3.28 2.22a.75.75 0 00-1.06 1.06l14.5 14.5a.75.75 0 101.06-1.06l-1.745-1.745a10.029 10.029 0 003.3-4.38 1.651 1.651 0 000-1.185A10.004 10.004 0 009.999 3a9.956 9.956 0 00-4.744 1.194L3.28 2.22zM7.752 6.69l1.092 1.092a2.5 2.5 0 013.374 3.373l1.091 1.092a4 4 0 00-5.557-5.557z" clip-rule="evenodd"></path><path d="M10.748 13.93l2.523 2.523a9.987 9.987 0 01-3.27.547c-4.258 0-7.894-2.66-9.337-6.41a1.651 1.651 0 010-1.186A10.007 10.007 0 012.839 6.02L6.07 9.252a4 4 0 004.678 4.678z"></path>'
    }
  }

  checkStrength() {
    const password = this.inputTarget.value
    const strength = this.calculateStrength(password)
    
    this.updateStrengthUI(strength)
  }

  calculateStrength(password) {
    let strength = 0
    
    if (password.length === 0) return 0
    if (password.length >= 8) strength += 25
    if (password.length >= 12) strength += 25
    if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength += 25
    if (/\d/.test(password)) strength += 15
    if (/[^a-zA-Z\d]/.test(password)) strength += 10
    
    return Math.min(strength, 100)
  }

  updateStrengthUI(strength) {
    const bar = this.strengthBarTarget
    const text = this.strengthTextTarget
    const password = this.inputTarget.value

    // Update bar width
    bar.style.width = `${strength}%`

    // Update colors and text
    if (password.length === 0) {
      bar.className = "h-full rounded-full transition-all duration-300"
      text.textContent = ""
      text.className = "text-sm font-medium"
    } else if (strength < 40) {
      bar.className = "h-full rounded-full bg-red-500 transition-all duration-300"
      text.textContent = "Weak"
      text.className = "text-sm font-medium text-red-600"
    } else if (strength < 70) {
      bar.className = "h-full rounded-full bg-yellow-500 transition-all duration-300"
      text.textContent = "Fair"
      text.className = "text-sm font-medium text-yellow-600"
    } else if (strength < 90) {
      bar.className = "h-full rounded-full bg-blue-500 transition-all duration-300"
      text.textContent = "Good"
      text.className = "text-sm font-medium text-blue-600"
    } else {
      bar.className = "h-full rounded-full bg-green-500 transition-all duration-300"
      text.textContent = "Strong"
      text.className = "text-sm font-medium text-green-600"
    }
  }
}

