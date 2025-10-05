import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["notification"]
  static values = {
    interval: { type: Number, default: 8000 }
  }

  connect() {
    this.activities = [
      { name: "Sarah M.", action: "booked a Business Consulting session", time: "2 minutes ago", location: "New York, NY" },
      { name: "Michael R.", action: "started a Wellness Coaching program", time: "5 minutes ago", location: "Los Angeles, CA" },
      { name: "Jennifer K.", action: "completed a Legal Advisory session", time: "8 minutes ago", location: "Chicago, IL" },
      { name: "David L.", action: "booked a Financial Planning consultation", time: "12 minutes ago", location: "Houston, TX" },
      { name: "Emily S.", action: "joined a Nutrition Coaching program", time: "15 minutes ago", location: "Phoenix, AZ" },
      { name: "Robert T.", action: "booked a Career Coaching session", time: "18 minutes ago", location: "Philadelphia, PA" },
      { name: "Lisa W.", action: "started a Mental Health session", time: "22 minutes ago", location: "San Antonio, TX" },
      { name: "James H.", action: "completed a Tax Advisory consultation", time: "25 minutes ago", location: "San Diego, CA" },
      { name: "Maria G.", action: "booked a Life Coaching session", time: "28 minutes ago", location: "Dallas, TX" },
      { name: "Thomas B.", action: "started a Business Strategy session", time: "32 minutes ago", location: "San Jose, CA" }
    ]

    this.currentIndex = 0
    this.showNextActivity()
    this.startRotation()
  }

  disconnect() {
    if (this.rotationTimer) {
      clearInterval(this.rotationTimer)
    }
  }

  startRotation() {
    this.rotationTimer = setInterval(() => {
      this.showNextActivity()
    }, this.intervalValue)
  }

  showNextActivity() {
    const activity = this.activities[this.currentIndex]
    this.displayActivity(activity)
    this.currentIndex = (this.currentIndex + 1) % this.activities.length
  }

  displayActivity(activity) {
    const html = `
      <div class="bg-white rounded-xl shadow-2xl p-4 max-w-sm border-l-4 border-indigo-600 transform transition-all duration-500">
        <div class="flex items-start gap-3">
          <div class="flex-shrink-0">
            <div class="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-500 rounded-full flex items-center justify-center text-white font-bold">
              ${activity.name.charAt(0)}
            </div>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-semibold text-gray-900">${activity.name}</p>
            <p class="text-sm text-gray-600">${activity.action}</p>
            <div class="flex items-center gap-2 mt-1">
              <svg class="w-3 h-3 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z"/>
              </svg>
              <span class="text-xs text-gray-500">${activity.time}</span>
            </div>
          </div>
          <div class="flex-shrink-0">
            <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
          </div>
        </div>
      </div>
    `

    // Fade out
    this.notificationTarget.style.opacity = '0'
    this.notificationTarget.style.transform = 'translateX(-100%)'

    setTimeout(() => {
      this.notificationTarget.innerHTML = html
      // Fade in
      this.notificationTarget.style.opacity = '1'
      this.notificationTarget.style.transform = 'translateX(0)'
    }, 300)
  }
}

