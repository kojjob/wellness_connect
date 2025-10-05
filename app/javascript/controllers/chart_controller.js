import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js"

// Connects to data-controller="chart"
export default class extends Controller {
  static values = {
    type: { type: String, default: "bar" },
    data: Object,
    options: { type: Object, default: {} }
  }

  connect() {
    this.initializeChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  initializeChart() {
    const ctx = this.element.getContext('2d')

    // Default options for better UX
    const defaultOptions = {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: this.typeValue !== 'line',
          position: 'bottom'
        },
        tooltip: {
          mode: 'index',
          intersect: false
        }
      },
      scales: this.typeValue === 'pie' || this.typeValue === 'doughnut' ? {} : {
        y: {
          beginAtZero: true,
          ticks: {
            callback: function(value) {
              // Format as currency if the value looks like money
              if (value >= 1000) {
                return '$' + (value / 1000).toFixed(1) + 'k'
              }
              return '$' + value
            }
          }
        }
      }
    }

    // Merge user options with defaults
    const finalOptions = this.deepMerge(defaultOptions, this.optionsValue)

    this.chart = new Chart(ctx, {
      type: this.typeValue,
      data: this.dataValue,
      options: finalOptions
    })
  }

  // Helper method to deep merge objects
  deepMerge(target, source) {
    const output = Object.assign({}, target)
    if (this.isObject(target) && this.isObject(source)) {
      Object.keys(source).forEach(key => {
        if (this.isObject(source[key])) {
          if (!(key in target)) {
            Object.assign(output, { [key]: source[key] })
          } else {
            output[key] = this.deepMerge(target[key], source[key])
          }
        } else {
          Object.assign(output, { [key]: source[key] })
        }
      })
    }
    return output
  }

  isObject(item) {
    return item && typeof item === 'object' && !Array.isArray(item)
  }

  // Public method to update chart data
  updateData(newData) {
    if (this.chart) {
      this.chart.data = newData
      this.chart.update()
    }
  }
}
