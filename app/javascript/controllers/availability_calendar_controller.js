import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="availability-calendar"
export default class extends Controller {
  static targets = ["modal", "calendar", "selectedDate", "timeSlots", "monthYear"]
  static values = {
    providerId: Number,
    availabilities: Array
  }

  connect() {
    console.log("Availability calendar controller connected")
    this.currentDate = new Date()
    this.selectedDate = null
    
    // Parse availabilities if they're passed as JSON
    if (this.hasAvailabilitiesValue) {
      this.availabilities = this.availabilitiesValue
    }
  }

  openModal(event) {
    event.preventDefault()
    this.modalTarget.classList.remove('hidden')
    this.modalTarget.classList.add('flex')
    document.body.style.overflow = 'hidden'
    
    // Render the calendar
    this.renderCalendar()
  }

  closeModal(event) {
    if (event) event.preventDefault()
    this.modalTarget.classList.add('hidden')
    this.modalTarget.classList.remove('flex')
    document.body.style.overflow = 'auto'
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.closeModal(event)
    }
  }

  previousMonth(event) {
    event.preventDefault()
    this.currentDate.setMonth(this.currentDate.getMonth() - 1)
    this.renderCalendar()
  }

  nextMonth(event) {
    event.preventDefault()
    this.currentDate.setMonth(this.currentDate.getMonth() + 1)
    this.renderCalendar()
  }

  renderCalendar() {
    const year = this.currentDate.getFullYear()
    const month = this.currentDate.getMonth()
    
    // Update month/year display
    const monthNames = ["January", "February", "March", "April", "May", "June",
                        "July", "August", "September", "October", "November", "December"]
    this.monthYearTarget.textContent = `${monthNames[month]} ${year}`
    
    // Get first day of month and number of days
    const firstDay = new Date(year, month, 1).getDay()
    const daysInMonth = new Date(year, month + 1, 0).getDate()
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    
    // Build calendar HTML
    let calendarHTML = '<div class="grid grid-cols-7 gap-2">'
    
    // Day headers
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    dayNames.forEach(day => {
      calendarHTML += `<div class="text-center text-xs font-semibold text-gray-600 py-2">${day}</div>`
    })
    
    // Empty cells for days before month starts
    for (let i = 0; i < firstDay; i++) {
      calendarHTML += '<div class="aspect-square"></div>'
    }
    
    // Days of the month
    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(year, month, day)
      date.setHours(0, 0, 0, 0)
      const dateStr = date.toISOString().split('T')[0]
      
      // Check if this date has availabilities
      const hasAvailability = this.hasAvailabilityOnDate(date)
      const isPast = date < today
      const isToday = date.getTime() === today.getTime()
      const isSelected = this.selectedDate && date.toDateString() === this.selectedDate.toDateString()
      
      let classes = 'aspect-square flex items-center justify-center rounded-lg text-sm font-medium transition cursor-pointer'
      
      if (isPast) {
        classes += ' text-gray-300 cursor-not-allowed'
      } else if (isSelected) {
        classes += ' bg-indigo-600 text-white ring-2 ring-indigo-600 ring-offset-2'
      } else if (hasAvailability) {
        classes += ' bg-green-50 text-green-700 hover:bg-green-100 border-2 border-green-200'
      } else if (isToday) {
        classes += ' bg-gray-100 text-gray-900 border-2 border-indigo-300'
      } else {
        classes += ' text-gray-400 hover:bg-gray-50'
      }
      
      const clickHandler = !isPast && hasAvailability ? `data-action="click->availability-calendar#selectDate" data-date="${dateStr}"` : ''
      
      calendarHTML += `<div class="${classes}" ${clickHandler}>${day}</div>`
    }
    
    calendarHTML += '</div>'
    
    this.calendarTarget.innerHTML = calendarHTML
  }

  hasAvailabilityOnDate(date) {
    if (!this.availabilities || this.availabilities.length === 0) return false
    
    const dateStr = date.toISOString().split('T')[0]
    
    return this.availabilities.some(avail => {
      const availDate = new Date(avail.start_time).toISOString().split('T')[0]
      return availDate === dateStr && !avail.is_booked
    })
  }

  selectDate(event) {
    const dateStr = event.currentTarget.dataset.date
    this.selectedDate = new Date(dateStr + 'T00:00:00')
    
    // Re-render calendar to show selection
    this.renderCalendar()
    
    // Show time slots for selected date
    this.renderTimeSlots()
  }

  renderTimeSlots() {
    if (!this.selectedDate) {
      this.timeSlotsTarget.innerHTML = '<p class="text-gray-500 text-center py-8">Select a date to view available time slots</p>'
      return
    }
    
    const dateStr = this.selectedDate.toISOString().split('T')[0]
    const slotsForDate = this.availabilities.filter(avail => {
      const availDate = new Date(avail.start_time).toISOString().split('T')[0]
      return availDate === dateStr && !avail.is_booked
    })
    
    if (slotsForDate.length === 0) {
      this.timeSlotsTarget.innerHTML = '<p class="text-gray-500 text-center py-8">No available time slots for this date</p>'
      return
    }
    
    // Sort by start time
    slotsForDate.sort((a, b) => new Date(a.start_time) - new Date(b.start_time))
    
    // Update selected date display
    const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
    this.selectedDateTarget.textContent = this.selectedDate.toLocaleDateString('en-US', options)
    
    // Render time slots
    let slotsHTML = '<div class="grid grid-cols-2 gap-3">'
    
    slotsForDate.forEach(slot => {
      const startTime = new Date(slot.start_time)
      const endTime = new Date(slot.end_time)
      const timeStr = `${this.formatTime(startTime)} - ${this.formatTime(endTime)}`
      
      slotsHTML += `
        <a href="/appointments/new?provider_profile_id=${this.providerIdValue}&availability_id=${slot.id}" 
           class="flex flex-col items-center justify-center p-4 bg-white border-2 border-indigo-200 rounded-lg hover:border-indigo-400 hover:bg-indigo-50 transition group">
          <svg class="w-5 h-5 text-indigo-600 mb-2 group-hover:scale-110 transition" fill="currentColor" viewBox="0 0 24 24">
            <path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z"/>
          </svg>
          <span class="text-sm font-semibold text-gray-900">${timeStr}</span>
          <span class="text-xs text-indigo-600 mt-1 group-hover:underline">Book Now</span>
        </a>
      `
    })
    
    slotsHTML += '</div>'
    
    this.timeSlotsTarget.innerHTML = slotsHTML
  }

  formatTime(date) {
    return date.toLocaleTimeString('en-US', { 
      hour: 'numeric', 
      minute: '2-digit',
      hour12: true 
    })
  }

  // Handle escape key to close modal
  handleKeydown(event) {
    if (event.key === 'Escape') {
      this.closeModal(event)
    }
  }
}

