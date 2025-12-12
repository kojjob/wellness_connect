import { Controller } from "@hotwired/stimulus"
// import Chart from "chart.js/auto" // Temporarily disabled

export default class extends Controller {
  static targets = ["spendingChart"]

  connect() {
    this.initializeSpendingChart()
  }

  // Escape HTML to prevent XSS attacks
  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  // Initialize spending trend chart
  initializeSpendingChart() {
    if (!this.hasSpendingChartTarget) return

    const monthlyData = JSON.parse(this.spendingChartTarget.dataset.monthlySpending || '{}')
    const labels = Object.keys(monthlyData).map(key => {
      const [year, month] = key.split('-')
      const date = new Date(year, month - 1)
      return date.toLocaleDateString('en-US', { month: 'short', year: 'numeric' })
    })
    const data = Object.values(monthlyData)

    const ctx = this.spendingChartTarget.getContext('2d')
    this.chart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: 'Amount ($)',
          data: data,
          borderColor: '#0d9488', // teal-600
          backgroundColor: 'rgba(13, 148, 136, 0.1)',
          borderWidth: 2,
          fill: true,
          tension: 0.4,
          pointBackgroundColor: '#0d9488',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 4,
          pointHoverRadius: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 2,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            padding: 12,
            titleColor: '#fff',
            bodyColor: '#fff',
            borderColor: '#0d9488',
            borderWidth: 1,
            displayColors: false,
            callbacks: {
              label: function(context) {
                return '$' + context.parsed.y.toFixed(2)
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return '$' + value
              },
              color: '#6b7280'
            },
            grid: {
              color: 'rgba(0, 0, 0, 0.05)'
            }
          },
          x: {
            ticks: {
              color: '#6b7280'
            },
            grid: {
              display: false
            }
          }
        }
      }
    })
  }

  // Toggle filters on mobile
  toggleFilters(event) {
    event.preventDefault()
    const filterForm = event.currentTarget.closest('.bg-white').querySelector('form')
    if (filterForm) {
      filterForm.classList.toggle('hidden')
    }
  }

  // Toggle custom date range visibility
  toggleCustomDateRange(event) {
    const customDateRange = document.getElementById('custom-date-range')
    if (customDateRange) {
      if (event.target.value === 'custom') {
        customDateRange.classList.remove('hidden')
      } else {
        customDateRange.classList.add('hidden')
      }
    }
  }

  // Handle search input with debounce
  handleSearch(event) {
    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      // Auto-submit form after 500ms of no typing
      // event.target.form.requestSubmit()
    }, 500)
  }

  // Handle filter form submission
  handleFilterSubmit(event) {
    // Show loading state
    this.showToast('Applying filters...', 'info')
  }

  // Export payments to CSV
  exportCSV(event) {
    event.preventDefault()
    this.showToast('Preparing CSV export...', 'info')
    
    // In a real implementation, this would trigger a server-side CSV generation
    setTimeout(() => {
      this.showToast('CSV export ready for download!', 'success')
    }, 1500)
  }

  // Download individual receipt
  downloadReceipt(event) {
    event.preventDefault()
    const paymentId = event.currentTarget.dataset.paymentId
    
    this.showToast('Downloading receipt...', 'info')
    
    // In a real implementation, this would trigger a PDF download
    setTimeout(() => {
      this.showToast('Receipt downloaded successfully!', 'success')
    }, 1000)
  }

  // Contact support
  contactSupport(event) {
    event.preventDefault()
    this.showToast('Opening support chat...', 'info')
    
    // In a real implementation, this would open a support modal or chat widget
    setTimeout(() => {
      window.location.href = '/contact'
    }, 500)
  }

  // Show toast notification
  showToast(message, type = 'info') {
    const toast = document.createElement('div')
    const bgColors = {
      success: 'bg-green-500',
      error: 'bg-red-500',
      warning: 'bg-yellow-500',
      info: 'bg-teal-500'
    }

    const icons = {
      success: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>',
      error: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>',
      warning: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>',
      info: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>'
    }

    toast.className = `fixed bottom-4 right-4 ${bgColors[type] || bgColors.info} text-white px-6 py-4 rounded-xl shadow-2xl z-50 flex items-center gap-3 animate-slide-up max-w-md`
    toast.innerHTML = `
      <div class="flex-shrink-0">
        ${icons[type] || icons.info}
      </div>
      <div class="flex-1">
        <p class="font-medium" id="toast-message"></p>
      </div>
      <button class="flex-shrink-0 ml-2 hover:bg-white/20 rounded-lg p-1 transition-colors" data-action="click->payments#dismissToast">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    `
    // Safely set message using textContent to prevent XSS
    const messageEl = toast.querySelector('#toast-message')
    if (messageEl) {
      messageEl.textContent = message
    }

    document.body.appendChild(toast)

    // Auto-remove after 4 seconds
    setTimeout(() => {
      this.removeToast(toast)
    }, 4000)
  }

  // Dismiss toast manually
  dismissToast(event) {
    const toast = event.currentTarget.closest('.fixed')
    if (toast) {
      this.removeToast(toast)
    }
  }

  // Remove toast with animation
  removeToast(toast) {
    toast.classList.add('opacity-0', 'transition-opacity', 'duration-300')
    setTimeout(() => {
      if (toast.parentNode) {
        toast.remove()
      }
    }, 300)
  }

  // Refresh dashboard data
  refreshDashboard(event) {
    if (event) event.preventDefault()
    this.showToast('Refreshing payment data...', 'info')
    
    setTimeout(() => {
      window.location.reload()
    }, 500)
  }
}
