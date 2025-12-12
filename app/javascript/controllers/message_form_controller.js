import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="message-form"
export default class extends Controller {
  clearForm(event) {
    if (!event?.detail?.success) return

    const textarea = this.element.querySelector("textarea")
    if (!textarea) return

    textarea.value = ""
    textarea.style.height = "auto"
    textarea.focus()
  }

  handleKeydown(event) {
    // Submit form on Enter (but not Shift+Enter for multiline)
    if (event.key !== "Enter" || event.shiftKey) return

    event.preventDefault()

    if (!event.target.value.trim()) return

    const form = event.target.closest("form")
    if (!form) return

    form.requestSubmit()
  }
}
