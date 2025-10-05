import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: { type: String, default: window.location.href },
    title: { type: String, default: document.title },
    text: String
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
    this.openPopup(url, 'Facebook', 555, 640)
  }

  shareLinkedIn(event) {
    event.preventDefault()
    const url = `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(this.urlValue)}`
    this.openPopup(url, 'LinkedIn', 550, 730)
  }

  shareEmail(event) {
    event.preventDefault()
    const subject = this.titleValue
    const body = `${this.textValue || ''}\n\n${this.urlValue}`
    window.location.href = `mailto:?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`
  }

  copyLink(event) {
    event.preventDefault()
    navigator.clipboard.writeText(this.urlValue).then(() => {
      this.showCopyFeedback(event.currentTarget)
    })
  }

  shareNative(event) {
    event.preventDefault()
    if (navigator.share) {
      navigator.share({
        title: this.titleValue,
        text: this.textValue,
        url: this.urlValue
      }).catch(err => {
        console.log('Error sharing:', err)
      })
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

  showCopyFeedback(button) {
    const originalText = button.textContent
    button.textContent = 'Copied!'
    button.classList.add('bg-green-600')
    
    setTimeout(() => {
      button.textContent = originalText
      button.classList.remove('bg-green-600')
    }, 2000)
  }
}

