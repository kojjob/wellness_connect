# frozen_string_literal: true

# Rack::Attack configuration for rate limiting and request throttling
# Documentation: https://github.com/rack/rack-attack

class Rack::Attack
  ### Configure Cache ###

  # Use Rails cache for storing rate limit data
  # Solid Cache (database-backed) is configured in production
  Rack::Attack.cache.store = Rails.cache

  ### Throttle Configuration ###

  # Throttle all requests by IP (general protection)
  # Limit: 300 requests per 5 minutes per IP
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # Throttle login attempts by IP address
  # Limit: 5 login attempts per 20 seconds
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.ip
    end
  end

  # Throttle login attempts by email parameter
  # Limit: 5 login attempts per 20 seconds per email
  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      # Return the email being used for login
      req.params["user"]&.dig("email")&.to_s&.downcase&.presence
    end
  end

  # Throttle password reset requests
  # Limit: 5 requests per hour per IP
  throttle("password_resets/ip", limit: 5, period: 1.hour) do |req|
    if req.path == "/users/password" && req.post?
      req.ip
    end
  end

  # Throttle registration attempts
  # Limit: 10 registrations per hour per IP
  throttle("registrations/ip", limit: 10, period: 1.hour) do |req|
    if req.path == "/users" && req.post?
      req.ip
    end
  end

  # Throttle API requests more strictly (if API endpoints are added later)
  # Limit: 60 requests per minute per IP for API endpoints
  throttle("api/ip", limit: 60, period: 1.minute) do |req|
    if req.path.start_with?("/api/")
      req.ip
    end
  end

  # Throttle appointment booking attempts
  # Limit: 20 bookings per hour per IP (prevents booking spam)
  throttle("bookings/ip", limit: 20, period: 1.hour) do |req|
    if req.path == "/appointments" && req.post?
      req.ip
    end
  end

  ### Blocklists ###

  # Block requests from known bad actors
  # Add IPs to this array to block them entirely
  blocklist("block_bad_ips") do |req|
    # Example: %w[1.2.3.4 5.6.7.8].include?(req.ip)
    false # No IPs blocked by default
  end

  ### Safelists ###

  # Always allow requests from localhost in development
  safelist("allow_localhost") do |req|
    # Allow localhost requests in development
    req.ip == "127.0.0.1" || req.ip == "::1" if Rails.env.development?
  end

  ### Custom Responses ###

  # Customize response for throttled requests
  self.throttled_responder = lambda do |request|
    retry_after = (request.env["rack.attack.match_data"] || {})[:period]

    [
      429, # HTTP 429 Too Many Requests
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [{ error: "Rate limit exceeded. Please try again later." }.to_json]
    ]
  end

  # Customize response for blocked requests
  self.blocklisted_responder = lambda do |_request|
    [
      403, # HTTP 403 Forbidden
      { "Content-Type" => "application/json" },
      [{ error: "Forbidden" }.to_json]
    ]
  end

  ### Logging ###

  # Log blocked requests
  ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
    req = payload[:request]

    if [:blocklist, :throttle].include?(req.env["rack.attack.match_type"])
      Rails.logger.warn "[Rack::Attack] #{req.env['rack.attack.match_type']}: #{req.ip} - #{req.path}"
    end
  end
end
