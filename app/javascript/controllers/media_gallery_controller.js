import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="media-gallery"
export default class extends Controller {
  static targets = ["lightbox", "lightboxContent", "lightboxImage", "lightboxVideo", "lightboxAudio", "lightboxPdf", "caption", "counter"]
  static values = {
    currentIndex: Number,
    items: Array
  }

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  openLightbox(event) {
    event.preventDefault()
    const index = parseInt(event.currentTarget.dataset.index)
    this.currentIndexValue = index
    this.showItem(index)
    this.lightboxTarget.classList.remove("hidden")
    this.lightboxTarget.classList.add("flex")
    document.body.style.overflow = "hidden"
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  closeLightbox() {
    this.lightboxTarget.classList.add("hidden")
    this.lightboxTarget.classList.remove("flex")
    document.body.style.overflow = ""
    document.removeEventListener("keydown", this.boundHandleKeydown)
    this.resetMedia()
  }

  previous(event) {
    event.preventDefault()
    event.stopPropagation()
    const totalItems = this.element.querySelectorAll("[data-index]").length
    this.currentIndexValue = (this.currentIndexValue - 1 + totalItems) % totalItems
    this.showItem(this.currentIndexValue)
  }

  next(event) {
    event.preventDefault()
    event.stopPropagation()
    const totalItems = this.element.querySelectorAll("[data-index]").length
    this.currentIndexValue = (this.currentIndexValue + 1) % totalItems
    this.showItem(this.currentIndexValue)
  }

  showItem(index) {
    const item = this.element.querySelector(`[data-index="${index}"]`)
    if (!item) return

    this.resetMedia()

    const type = item.dataset.type
    const url = item.dataset.url
    const caption = item.dataset.caption || ""

    // Update counter
    const totalItems = this.element.querySelectorAll("[data-index]").length
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${index + 1} / ${totalItems}`
    }

    // Update caption
    if (this.hasCaptionTarget) {
      this.captionTarget.textContent = caption
    }

    // Show appropriate media type
    switch(type) {
      case "image":
        this.showImage(url, caption)
        break
      case "video":
        this.showVideo(url)
        break
      case "audio":
        this.showAudio(url, caption)
        break
      case "pdf":
        this.showPdf(url, caption)
        break
    }
  }

  showImage(url, alt) {
    if (this.hasLightboxImageTarget) {
      this.lightboxImageTarget.src = url
      this.lightboxImageTarget.alt = alt
      this.lightboxImageTarget.classList.remove("hidden")
    }
  }

  showVideo(url) {
    if (this.hasLightboxVideoTarget) {
      this.lightboxVideoTarget.src = url
      this.lightboxVideoTarget.classList.remove("hidden")
      this.lightboxVideoTarget.play()
    }
  }

  showAudio(url, caption) {
    if (this.hasLightboxAudioTarget) {
      this.lightboxAudioTarget.src = url
      this.lightboxAudioTarget.classList.remove("hidden")
    }
  }

  showPdf(url, caption) {
    if (this.hasLightboxPdfTarget) {
      this.lightboxPdfTarget.src = url
      this.lightboxPdfTarget.classList.remove("hidden")
    }
  }

  resetMedia() {
    if (this.hasLightboxImageTarget) {
      this.lightboxImageTarget.classList.add("hidden")
      this.lightboxImageTarget.src = ""
    }
    if (this.hasLightboxVideoTarget) {
      this.lightboxVideoTarget.classList.add("hidden")
      this.lightboxVideoTarget.pause()
      this.lightboxVideoTarget.src = ""
    }
    if (this.hasLightboxAudioTarget) {
      this.lightboxAudioTarget.classList.add("hidden")
      this.lightboxAudioTarget.pause()
      this.lightboxAudioTarget.src = ""
    }
    if (this.hasLightboxPdfTarget) {
      this.lightboxPdfTarget.classList.add("hidden")
      this.lightboxPdfTarget.src = ""
    }
  }

  handleKeydown(event) {
    switch(event.key) {
      case "Escape":
        this.closeLightbox()
        break
      case "ArrowLeft":
        this.previous(event)
        break
      case "ArrowRight":
        this.next(event)
        break
    }
  }

  handleBackdropClick(event) {
    if (event.target === this.lightboxTarget) {
      this.closeLightbox()
    }
  }
}

