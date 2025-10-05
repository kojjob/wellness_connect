import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="payment"
export default class extends Controller {
  static targets = [
    "form",
    "cardElement",
    "cardErrors",
    "submitButton",
    "serviceSelect",
    "amount"
  ]

  static values = {
    publishableKey: String,
    availabilityId: String
  }

  connect() {
    // Initialize Stripe with publishable key from data attribute
    this.stripe = Stripe(this.publishableKeyValue)

    // Create card element
    const elements = this.stripe.elements()
    this.cardElement = elements.create('card', {
      style: {
        base: {
          fontSize: '16px',
          color: '#1f2937',
          fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
          '::placeholder': {
            color: '#9ca3af'
          }
        },
        invalid: {
          color: '#ef4444',
          iconColor: '#ef4444'
        }
      }
    })

    // Mount the card element
    this.cardElement.mount(this.cardElementTarget)

    // Listen for validation errors
    this.cardElement.on('change', (event) => {
      if (event.error) {
        this.showCardError(event.error.message)
      } else {
        this.clearCardError()
      }
    })
  }

  disconnect() {
    if (this.cardElement) {
      this.cardElement.destroy()
    }
  }

  async submit(event) {
    event.preventDefault()

    // Disable submit button
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.textContent = 'Processing...'

    try {
      // First, create the appointment and payment intent
      const formData = new FormData(this.formTarget)
      formData.append('availability_id', this.availabilityIdValue)

      const response = await fetch(this.formTarget.action, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: formData
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Failed to create appointment')
      }

      // Confirm the payment with Stripe
      const { error, paymentIntent } = await this.stripe.confirmCardPayment(
        data.client_secret,
        {
          payment_method: {
            card: this.cardElement
          }
        }
      )

      if (error) {
        // Payment failed
        this.showCardError(error.message)
        this.submitButtonTarget.disabled = false
        this.submitButtonTarget.textContent = 'Confirm Booking'
      } else if (paymentIntent.status === 'succeeded') {
        // Payment succeeded - redirect to dashboard
        window.location.href = '/dashboard?payment_success=true'
      } else {
        // Payment is processing or requires additional action
        this.showCardError('Payment is being processed. Please check your email for confirmation.')
        setTimeout(() => {
          window.location.href = '/dashboard'
        }, 3000)
      }
    } catch (error) {
      this.showCardError(error.message)
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.textContent = 'Confirm Booking'
    }
  }

  showCardError(message) {
    this.cardErrorsTarget.textContent = message
    this.cardErrorsTarget.classList.remove('hidden')
  }

  clearCardError() {
    this.cardErrorsTarget.textContent = ''
    this.cardErrorsTarget.classList.add('hidden')
  }

  // Update displayed amount when service selection changes
  serviceChanged() {
    const selectedOption = this.serviceSelectTarget.options[this.serviceSelectTarget.selectedIndex]
    const price = selectedOption.dataset.price

    if (price) {
      this.amountTarget.textContent = `$${parseFloat(price).toFixed(2)}`
    }
  }
}
