# frozen_string_literal: true

# Secure Session Configuration
# Configures encrypted, secure session cookies with appropriate security flags

Rails.application.config.session_store :cookie_store,
  key: "_wellness_connect_session",
  # Use encrypted cookies for session data
  # Rails automatically encrypts with secret_key_base
  secure: Rails.env.production?,  # Require HTTPS in production
  httponly: true,                  # Prevent JavaScript access to session cookie
  same_site: :lax,                # CSRF protection via SameSite attribute
  expire_after: 2.weeks           # Session expires after 2 weeks of inactivity
