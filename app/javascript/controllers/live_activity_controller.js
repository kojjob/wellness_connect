import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["notification"]
  static values = {
    interval: { type: Number, default: 8000 }
  }

  connect() {
    this.activities = [
      { name: "Sarah J.", action: "booked a therapy session", location: "New York", time: "2 min ago", icon: "user" },
      { name: "Michael C.", action: "started nutrition counseling", location: "Los Angeles", time: "5 min ago", icon: "heart" },
      { name: "Emma R.", action: "joined a fitness program", location: "Chicago", time: "8 min ago", icon: "lightning" },
      { name: "David T.", action: "booked a wellness consultation", location: "Houston", time: "12 min ago", icon: "star" },
      { name: "Lisa M.", action: "started mental health therapy", location: "Phoenix", time: "15 min ago", icon: "user" },
      { name: "James K.", action: "booked alternative medicine session", location: "Philadelphia", time: "18 min ago", icon: "heart" },
      { name: "Maria G.", action: "joined yoga classes", location: "San Antonio", time: "22 min ago", icon: "lightning" },
      { name: "Robert L.", action: "started nutrition plan", location: "San Diego", time: "25 min ago", icon: "star" },
      { name: "Jennifer W.", action: "booked fitness coaching", location: "Dallas", time: "28 min ago", icon: "user" },
      { name: "William B.", action: "started therapy sessions", location: "San Jose", time: "32 min ago", icon: "heart" }
    ]
    
    this.showRandomActivity()
    this.intervalId = setInterval(() => this.showRandomActivity(), this.intervalValue)
  }

  disconnect() {
    if (this.intervalId) {
      clearInterval(this.intervalId)
    }
  }

  showRandomActivity() {
    const activity = this.activities[Math.floor(Math.random() * this.activities.length)]
    
    this.notificationTarget.innerHTML = `
      <div class="flex items-center gap-3 p-4 bg-white rounded-lg shadow-2xl border border-gray-100">
        <div class="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-500 rounded-full flex items-center justify-center flex-shrink-0">
          <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
            <path d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"/>
          </svg>
        </div>
        <div class="flex-1 min-w-0">
          <div class="font-semibold text-sm text-gray-900 truncate">
            ${activity.name} ${activity.action}
          </div>
          <div class="text-xs text-gray-500 flex items-center gap-2">
            <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z"/>
            </svg>
            ${activity.location}
            <span class="mx-1">•</span>
            ${activity.time}
          </div>
        </div>
        <button class="text-gray-400 hover:text-gray-600 flex-shrink-0" data-action="click->live-activity#close">
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"/>
          </svg>
        </button>
      </div>
    `
    
    // Slide in animation
    this.notificationTarget.classList.remove('translate-x-full', 'opacity-0')
    this.notificationTarget.classList.add('translate-x-0', 'opacity-100')
    
    // Slide out after 6 seconds
    setTimeout(() => {
      this.notificationTarget.classList.remove('translate-x-0', 'opacity-100')
      this.notificationTarget.classList.add('translate-x-full', 'opacity-0')
    }, 6000)
  }

  close(event) {
    event.preventDefault()
    this.notificationTarget.classList.add('translate-x-full', 'opacity-0')
  }
}

