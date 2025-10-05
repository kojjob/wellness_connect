import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="admin-user-profile"
export default class extends Controller {
  static targets = [
    "avatarInput",
    "avatarPreview",
    "avatarPlaceholder",
    "avatarUploadArea",
    "removeAvatarButton",
    "fileInput",
    "fileList",
    "uploadProgress",
    "tabButton",
    "tabPanel"
  ]

  static values = {
    userId: Number,
    currentTab: { type: String, default: "overview" }
  }

  connect() {
    console.log("Admin user profile controller connected")
    this.setupDragAndDrop()
    this.showTab(this.currentTabValue)
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
      return
    }

    // Validate file size (5MB max)
    if (file.size > 5 * 1024 * 1024) {
      alert('File size must be less than 5MB')
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
      if (this.hasRemoveAvatarButtonTarget) {
        this.removeAvatarButtonTarget.classList.remove('hidden')
      }
    }
    reader.readAsDataURL(file)

    // Auto-submit form to upload avatar
    this.uploadAvatar(file)
  }

  uploadAvatar(file) {
    const formData = new FormData()
    formData.append('user[avatar]', file)
    formData.append('authenticity_token', this.getCSRFToken())

    fetch(`/admin/users/${this.userIdValue}`, {
      method: 'PATCH',
      body: formData,
      headers: {
        'X-CSRF-Token': this.getCSRFToken()
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.showNotification('Avatar updated successfully', 'success')
      } else {
        this.showNotification('Failed to update avatar', 'error')
      }
    })
    .catch(error => {
      console.error('Error uploading avatar:', error)
      this.showNotification('Failed to update avatar', 'error')
    })
  }

  removeAvatar(event) {
    event.preventDefault()
    
    if (!confirm('Are you sure you want to remove the avatar?')) {
      return
    }

    fetch(`/admin/users/${this.userIdValue}/remove_avatar`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': this.getCSRFToken(),
        'Content-Type': 'application/json'
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        if (this.hasAvatarPreviewTarget) {
          this.avatarPreviewTarget.classList.add('hidden')
        }
        if (this.hasAvatarPlaceholderTarget) {
          this.avatarPlaceholderTarget.classList.remove('hidden')
        }
        if (this.hasRemoveAvatarButtonTarget) {
          this.removeAvatarButtonTarget.classList.add('hidden')
        }
        this.showNotification('Avatar removed successfully', 'success')
      } else {
        this.showNotification('Failed to remove avatar', 'error')
      }
    })
    .catch(error => {
      console.error('Error removing avatar:', error)
      this.showNotification('Failed to remove avatar', 'error')
    })
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
        // Create a fake file input event
        const dataTransfer = new DataTransfer()
        dataTransfer.items.add(file)
        this.avatarInputTarget.files = dataTransfer.files
        this.handleAvatarChange({ target: this.avatarInputTarget })
      }
    })
  }

  // Tab Navigation
  switchTab(event) {
    event.preventDefault()
    const tabName = event.currentTarget.dataset.tab
    this.showTab(tabName)
  }

  showTab(tabName) {
    this.currentTabValue = tabName

    // Update tab buttons
    this.tabButtonTargets.forEach(button => {
      const isActive = button.dataset.tab === tabName

      if (isActive) {
        button.classList.add('border-teal-600', 'text-teal-600')
        button.classList.remove('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300')
      } else {
        button.classList.remove('border-teal-600', 'text-teal-600')
        button.classList.add('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300')
      }
    })

    // Update tab panels
    this.tabPanelTargets.forEach(panel => {
      if (panel.dataset.tab === tabName) {
        panel.classList.remove('hidden')
      } else {
        panel.classList.add('hidden')
      }
    })
  }

  // Confirmation for destructive actions
  confirmAction(event) {
    const message = event.currentTarget.dataset.confirmMessage || "Are you sure?"
    if (!confirm(message)) {
      event.preventDefault()
      event.stopPropagation()
    }
  }

  // Helper methods
  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }

  showNotification(message, type = 'info') {
    // Create a simple toast notification
    const toast = document.createElement('div')
    toast.className = `fixed top-4 right-4 z-50 px-6 py-4 rounded-lg shadow-lg text-white ${
      type === 'success' ? 'bg-green-600' : 
      type === 'error' ? 'bg-red-600' : 
      'bg-blue-600'
    } transform transition-all duration-300 translate-x-full`
    toast.textContent = message

    document.body.appendChild(toast)

    // Animate in
    setTimeout(() => {
      toast.classList.remove('translate-x-full')
    }, 100)

    // Remove after 3 seconds
    setTimeout(() => {
      toast.classList.add('translate-x-full')
      setTimeout(() => {
        document.body.removeChild(toast)
      }, 300)
    }, 3000)
  }

  // Print functionality
  printProfile(event) {
    event.preventDefault()
    window.print()
  }
}
