import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gallery"
export default class extends Controller {
  static targets = ["lightbox", "lightboxImage", "lightboxVideo", "lightboxCaption", "thumbnails"]
  static values = {
    currentIndex: Number
  }

  connect() {
    this.currentIndexValue = 0
  }

  openLightbox(event) {
    event.preventDefault()
    const index = parseInt(event.currentTarget.dataset.index)
    this.currentIndexValue = index
    
    const mediaType = event.currentTarget.dataset.mediaType
    const mediaSrc = event.currentTarget.dataset.mediaSrc
    const caption = event.currentTarget.dataset.caption || ""
    
    this.showMedia(mediaType, mediaSrc, caption)
    this.lightboxTarget.classList.remove('hidden')
    this.lightboxTarget.classList.add('flex')
    document.body.style.overflow = 'hidden'
  }

  closeLightbox(event) {
    if (event) event.preventDefault()
    this.lightboxTarget.classList.add('hidden')
    this.lightboxTarget.classList.remove('flex')
    document.body.style.overflow = 'auto'
    
    // Pause any playing videos
    if (this.hasLightboxVideoTarget) {
      this.lightboxVideoTarget.pause()
    }
  }

  closeOnBackdrop(event) {
    if (event.target === this.lightboxTarget) {
      this.closeLightbox(event)
    }
  }

  showMedia(mediaType, mediaSrc, caption) {
    // Hide all media elements first
    if (this.hasLightboxImageTarget) {
      this.lightboxImageTarget.classList.add('hidden')
    }
    if (this.hasLightboxVideoTarget) {
      this.lightboxVideoTarget.classList.add('hidden')
      this.lightboxVideoTarget.pause()
    }
    
    // Show the appropriate media element
    if (mediaType === 'image') {
      this.lightboxImageTarget.src = mediaSrc
      this.lightboxImageTarget.classList.remove('hidden')
    } else if (mediaType === 'video') {
      this.lightboxVideoTarget.src = mediaSrc
      this.lightboxVideoTarget.classList.remove('hidden')
      this.lightboxVideoTarget.load()
    }
    
    // Update caption
    if (this.hasLightboxCaptionTarget) {
      this.lightboxCaptionTarget.textContent = caption
    }
  }

  previous(event) {
    event.preventDefault()
    const thumbnails = this.thumbnailsTarget.querySelectorAll('[data-index]')
    if (this.currentIndexValue > 0) {
      this.currentIndexValue--
      this.updateMedia(thumbnails)
    }
  }

  next(event) {
    event.preventDefault()
    const thumbnails = this.thumbnailsTarget.querySelectorAll('[data-index]')
    if (this.currentIndexValue < thumbnails.length - 1) {
      this.currentIndexValue++
      this.updateMedia(thumbnails)
    }
  }

  updateMedia(thumbnails) {
    const currentThumbnail = thumbnails[this.currentIndexValue]
    const mediaType = currentThumbnail.dataset.mediaType
    const mediaSrc = currentThumbnail.dataset.mediaSrc
    const caption = currentThumbnail.dataset.caption || ""
    
    this.showMedia(mediaType, mediaSrc, caption)
  }

  // Handle escape key to close lightbox
  handleKeydown(event) {
    if (event.key === 'Escape') {
      this.closeLightbox(event)
    } else if (event.key === 'ArrowLeft') {
      this.previous(event)
    } else if (event.key === 'ArrowRight') {
      this.next(event)
    }
  }

  disconnect() {
    document.body.style.overflow = 'auto'
  }
}

