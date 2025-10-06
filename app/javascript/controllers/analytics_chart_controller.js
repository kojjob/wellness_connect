import { Controller } from "@hotwired/stimulus"
// import Chart from "chart.js/auto" // Temporarily disabled

// Connects to data-controller="analytics-chart"
export default class extends Controller {
  static values = {
    type: String,
    data: Object,
    label: String,
    colors: Object
  }

  connect() {
    this.createChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  createChart() {
    const ctx = this.element.getContext('2d')
    const chartType = this.typeValue || 'bar'
    const chartData = this.dataValue || {}
    const label = this.labelValue || 'Data'
    const colors = this.colorsValue || this.getDefaultColors(chartType)

    this.chart = new Chart(ctx, {
      type: chartType,
      data: {
        labels: Object.keys(chartData),
        datasets: [{
          label: label,
          data: Object.values(chartData),
          backgroundColor: colors.background,
          borderColor: colors.border,
          borderWidth: 2,
          ...(chartType === 'bar' && { borderRadius: 4 }),
          ...(chartType === 'line' && {
            fill: true,
            tension: 0.4,
            pointBackgroundColor: colors.border,
            pointRadius: 4,
            pointHoverRadius: 6
          })
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            callbacks: {
              label: (context) => {
                let label = context.dataset.label || ''
                if (label) {
                  label += ': '
                }
                if (context.parsed.y !== null) {
                  label += '$' + context.parsed.y.toLocaleString('en-US', {
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2
                  })
                }
                return label
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: (value) => {
                return '$' + value.toLocaleString()
              }
            }
          },
          x: {
            grid: {
              display: false
            }
          }
        }
      }
    })
  }

  getDefaultColors(chartType) {
    if (chartType === 'bar') {
      return {
        background: 'rgba(13, 148, 136, 0.6)',
        border: 'rgba(13, 148, 136, 1)'
      }
    } else if (chartType === 'line') {
      return {
        background: 'rgba(59, 130, 246, 0.1)',
        border: 'rgba(59, 130, 246, 1)'
      }
    }
    return {
      background: 'rgba(107, 114, 128, 0.6)',
      border: 'rgba(107, 114, 128, 1)'
    }
  }
}
