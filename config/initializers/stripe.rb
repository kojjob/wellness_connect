# Configure Stripe with API keys from Rails credentials
# To add Stripe keys to credentials, run:
# EDITOR="code --wait" bin/rails credentials:edit
#
# Add the following to your credentials:
# stripe:
#   publishable_key: pk_test_...
#   secret_key: sk_test_...
#   webhook_secret: whsec_...

Rails.configuration.stripe = {
  publishable_key: Rails.application.credentials.dig(:stripe, :publishable_key),
  secret_key: Rails.application.credentials.dig(:stripe, :secret_key),
  webhook_secret: Rails.application.credentials.dig(:stripe, :webhook_secret)
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
