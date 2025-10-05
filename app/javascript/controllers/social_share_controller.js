import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    title: String,
    text: String
  }

  connect() {
    // Use current page URL if not specified
    this.urlValue = this.urlValue || window.location.href
    this.titleValue = this.titleValue || document.title
  }

  shareTwitter(event) {
    event.preventDefault()
    const text = this.textValue || this.titleValue
    const url = `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(this.urlValue)}`
    this.openPopup(url, 'Twitter', 550, 420)
  }

  shareFacebook(event) {
    event.preventDefault()
    const url = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(this.urlValue)}`
    this.openPopup(url, 'Facebook', 550, 420)
  }

  shareLinkedIn(event) {
    event.preventDefault()
    const url = `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(this.urlValue)}`
    this.openPopup(url, 'LinkedIn', 550, 420)
  }

  shareEmail(event) {
    event.preventDefault()
    const subject = this.titleValue
    const body = `${this.textValue || 'Check this out'}: ${this.urlValue}`
    window.location.href = `mailto:?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`
  }

  async copyLink(event) {
    event.preventDefault()
    
    try {
      await navigator.clipboard.writeText(this.urlValue)
      
      // Show success feedback
      const button = event.currentTarget
      const originalHTML = button.innerHTML
      button.innerHTML = `
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"/>
        </svg>
        <span>Copied!</span>
      `
      
      setTimeout(() => {
        button.innerHTML = originalHTML
      }, 2000)
    } catch (err) {
      console.error('Failed to copy:', err)
      // Fallback for older browsers
      this.fallbackCopyLink()
    }
  }

  async shareNative(event) {
    event.preventDefault()
    
    if (navigator.share) {
      try {
        await navigator.share({
          title: this.titleValue,
          text: this.textValue,
          url: this.urlValue
        })
      } catch (err) {
        // User cancelled or error occurred
        console.log('Share cancelled or failed:', err)
      }
    } else {
      // Fallback to copy link
      this.copyLink(event)
    }
  }

  openPopup(url, title, width, height) {
    const left = (screen.width - width) / 2
    const top = (screen.height - height) / 2
    const options = `width=${width},height=${height},left=${left},top=${top},menubar=no,toolbar=no,location=no,status=no`
    window.open(url, title, options)
  }

  fallbackCopyLink() {
    const textarea = document.createElement('textarea')
    textarea.value = this.urlValue
    textarea.style.position = 'fixed'
    textarea.style.opacity = '0'
    document.body.appendChild(textarea)
    textarea.select()
    
    try {
      document.execCommand('copy')
      alert('Link copied to clipboard!')
    } catch (err) {
      alert('Failed to copy link')
    }
    
    document.body.removeChild(textarea)
  }
}

