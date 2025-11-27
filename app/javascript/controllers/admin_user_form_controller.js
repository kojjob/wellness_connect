import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="admin-user-form"
export default class extends Controller {
  static targets = [
    "passwordInput",
    "passwordToggle",
    "passwordConfirmInput",
    "passwordConfirmToggle",
    "avatarInput",
    "avatarPreview",
    "avatarPlaceholder",
    "avatarUploadArea",
    "removeAvatarField",
    "submitButton"
  ]

  static values = {
    isDirty: { type: Boolean, default: false }
  }

  connect() {
    this.setupFormChangeDetection()
    this.setupDragAndDrop()
  }

  disconnect() {
    this.removeBeforeUnloadListener()
  }

  // Password visibility toggle
  togglePassword(event) {
    event.preventDefault()
    const input = this.passwordInputTarget
    const icon = event.currentTarget.querySelector('svg')
    
    if (input.type === 'password') {
      input.type = 'text'
      icon.innerHTML = `
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/>
      `
    } else {
      input.type = 'password'
      icon.innerHTML = `
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
      `
    }
  }

  togglePasswordConfirm(event) {
    event.preventDefault()
    const input = this.passwordConfirmInputTarget
    const icon = event.currentTarget.querySelector('svg')
    
    if (input.type === 'password') {
      input.type = 'text'
      icon.innerHTML = `
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/>
      `
    } else {
      input.type = 'password'
      icon.innerHTML = `
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
      `
    }
  }

  // Avatar Upload
  selectAvatar() {
    this.avatarInputTarget.click()
  }

  handleAvatarChange(event) {
    const file = event.target.files[0]
    if (!file) return

    // Validate file type
    if (!file.type.match('image.*')) {
      alert('Please select an image file (JPG, PNG, GIF)')
      event.target.value = ''
      return
    }

    // Validate file size (5MB max)
    if (file.size > 5 * 1024 * 1024) {
      alert('File size must be less than 5MB')
      event.target.value = ''
      return
    }

    // Preview image
    const reader = new FileReader()
    reader.onload = (e) => {
      if (this.hasAvatarPreviewTarget) {
        this.avatarPreviewTarget.src = e.target.result
        this.avatarPreviewTarget.classList.remove('hidden')
      }
      if (this.hasAvatarPlaceholderTarget) {
        this.avatarPlaceholderTarget.classList.add('hidden')
      }
    }
    reader.readAsDataURL(file)

    // Mark form as dirty
    this.markAsDirty()
  }

  removeAvatar(event) {
    event.preventDefault()
    
    if (!confirm('Are you sure you want to remove the avatar?')) {
      return
    }

    // Clear file input
    if (this.hasAvatarInputTarget) {
      this.avatarInputTarget.value = ''
    }

    // Hide preview, show placeholder
    if (this.hasAvatarPreviewTarget) {
      this.avatarPreviewTarget.classList.add('hidden')
      this.avatarPreviewTarget.src = ''
    }
    if (this.hasAvatarPlaceholderTarget) {
      this.avatarPlaceholderTarget.classList.remove('hidden')
    }

    // Set hidden field to mark avatar for removal
    if (this.hasRemoveAvatarFieldTarget) {
      this.removeAvatarFieldTarget.value = '1'
    }

    // Mark form as dirty
    this.markAsDirty()
  }

  // Drag and Drop
  setupDragAndDrop() {
    if (!this.hasAvatarUploadAreaTarget) return

    const area = this.avatarUploadAreaTarget

    area.addEventListener('dragover', (e) => {
      e.preventDefault()
      area.classList.add('border-teal-500', 'bg-teal-50')
    })

    area.addEventListener('dragleave', (e) => {
      e.preventDefault()
      area.classList.remove('border-teal-500', 'bg-teal-50')
    })

    area.addEventListener('drop', (e) => {
      e.preventDefault()
      area.classList.remove('border-teal-500', 'bg-teal-50')

      const file = e.dataTransfer.files[0]
      if (file && file.type.match('image.*')) {
        const dataTransfer = new DataTransfer()
        dataTransfer.items.add(file)
        this.avatarInputTarget.files = dataTransfer.files
        this.handleAvatarChange({ target: this.avatarInputTarget })
      }
    })
  }

  // Form change detection
  setupFormChangeDetection() {
    this.element.addEventListener('input', () => {
      this.markAsDirty()
    })

    this.element.addEventListener('change', () => {
      this.markAsDirty()
    })
  }

  markAsDirty() {
    if (!this.isDirtyValue) {
      this.isDirtyValue = true
      this.addBeforeUnloadListener()
    }
  }

  addBeforeUnloadListener() {
    this.beforeUnloadHandler = (e) => {
      e.preventDefault()
      e.returnValue = ''
      return ''
    }
    window.addEventListener('beforeunload', this.beforeUnloadHandler)
  }

  removeBeforeUnloadListener() {
    if (this.beforeUnloadHandler) {
      window.removeEventListener('beforeunload', this.beforeUnloadHandler)
    }
  }

  // Form submission
  handleSubmit(event) {
    // Remove beforeunload listener on form submit
    this.removeBeforeUnloadListener()
    
    // Disable submit button to prevent double submission
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.innerHTML = `
        <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white inline-block" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        Saving...
      `
    }
  }

  // Cancel with confirmation if form is dirty
  handleCancel(event) {
    if (this.isDirtyValue) {
      if (!confirm('You have unsaved changes. Are you sure you want to leave?')) {
        event.preventDefault()
        event.stopPropagation()
      } else {
        this.removeBeforeUnloadListener()
      }
    }
  }
}

