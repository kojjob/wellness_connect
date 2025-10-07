import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll-to-bottom"
// Automatically scrolls a container to the bottom when connected or when new content is added
export default class extends Controller {
  connect() {
    this.scrollToBottom()

    // Observe for new messages being added
    this.observer = new MutationObserver(() => {
      this.scrollToBottom()
    })

    this.observer.observe(this.element, {
      childList: true,
      subtree: true
    })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  scrollToBottom() {
    // Use smooth scrolling for better UX
    this.element.scrollTo({
      top: this.element.scrollHeight,
      behavior: 'smooth'
    })
  }

  // Method to scroll immediately without animation (useful for initial load)
  scrollToBottomInstant() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
