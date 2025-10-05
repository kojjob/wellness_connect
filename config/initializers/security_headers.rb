# frozen_string_literal: true

# Security Headers Configuration
# Adds comprehensive security headers to all HTTP responses
# Defense in depth strategy with multiple layers of protection

Rails.application.config.action_dispatch.default_headers.merge!(
  {
    # Prevent clickjacking attacks by disallowing framing
    # CSP frame-ancestors provides similar protection but this is more widely supported
    "X-Frame-Options" => "DENY",

    # Prevent MIME type sniffing
    # Forces browsers to respect declared content types
    "X-Content-Type-Options" => "nosniff",

    # Enable XSS protection in older browsers
    # Modern browsers use CSP instead, but this provides defense in depth
    "X-XSS-Protection" => "1; mode=block",

    # Control referrer information sent with requests
    # Protects user privacy while maintaining functionality
    "Referrer-Policy" => "strict-origin-when-cross-origin",

    # Control which browser features and APIs can be used
    # Restricts access to sensitive features like camera, microphone, geolocation
    "Permissions-Policy" => [
      "camera=()",           # No camera access
      "microphone=()",       # No microphone access
      "geolocation=()",      # No geolocation access
      "payment=(self)",      # Payment API only from same origin
      "usb=()",             # No USB access
      "magnetometer=()",    # No magnetometer access
      "accelerometer=()",   # No accelerometer access
      "gyroscope=()"        # No gyroscope access
    ].join(", ")
  }
)
