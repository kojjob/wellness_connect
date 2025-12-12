import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosize"
export default class extends Controller {
  resize(event) {
    const textarea = event.target
    textarea.style.height = "auto"
    const newHeight = Math.min(textarea.scrollHeight, 128) // max-h-32
    textarea.style.height = `${newHeight}px`
  }
}
