import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "item"]

  connect() {
    // Controller initialized
  }

  // Escape HTML to prevent XSS attacks
  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  filter(event) {
    const searchTerm = event.target.value.toLowerCase().trim()
    const conversationsList = document.getElementById('conversations-list')
    
    if (!conversationsList) {
      console.warn("Conversations list not found")
      return
    }

    const conversationItems = conversationsList.querySelectorAll('.group')
    let visibleCount = 0

    conversationItems.forEach(item => {
      const text = item.textContent.toLowerCase()
      
      if (searchTerm === '' || text.includes(searchTerm)) {
        item.style.display = ''
        visibleCount++
      } else {
        item.style.display = 'none'
      }
    })

    // Show/hide empty state if needed
    this.updateEmptyState(visibleCount, searchTerm)
  }

  updateEmptyState(visibleCount, searchTerm) {
    const conversationsList = document.getElementById('conversations-list')
    let emptyState = document.getElementById('search-empty-state')

    if (visibleCount === 0 && searchTerm !== '') {
      if (!emptyState) {
        emptyState = this.createEmptyState(searchTerm)
        conversationsList.parentElement.appendChild(emptyState)
      }
      emptyState.style.display = 'block'
    } else if (emptyState) {
      emptyState.style.display = 'none'
    }
  }

  createEmptyState(searchTerm) {
    const div = document.createElement('div')
    div.id = 'search-empty-state'
    div.className = 'bg-white rounded-2xl shadow-xl border-2 border-dashed border-gray-300 p-12 text-center mt-4'
    div.innerHTML = `
      <div class="mx-auto h-16 w-16 rounded-full bg-gray-100 flex items-center justify-center mb-4">
        <svg class="h-8 w-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
        </svg>
      </div>
      <h3 class="text-lg font-bold text-gray-900 mb-2">No conversations found</h3>
      <p class="text-gray-600">No conversations match "<span id="search-term-display"></span>". Try a different search term.</p>
    `
    // Safely set the search term using textContent to prevent XSS
    const searchTermSpan = div.querySelector('#search-term-display')
    if (searchTermSpan) {
      searchTermSpan.textContent = searchTerm
    }
    return div
  }

  clear() {
    const input = document.getElementById('conversation-search')
    if (input) {
      input.value = ''
      this.filter({ target: input })
    }
  }
}

