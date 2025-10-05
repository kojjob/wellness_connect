# frozen_string_literal: true

# Devise Security Event Logging
# Logs authentication events using Warden callbacks

Warden::Manager.after_set_user do |user, auth, opts|
  # Log successful authentication
  Rails.logger.info({
    event: "user_authenticated",
    timestamp: Time.current,
    user_id: user.id,
    user_email: user.email,
    user_role: user.role,
    scope: opts[:scope],
    event_type: opts[:event] || :authentication
  }.to_json)
end

Warden::Manager.before_failure do |env, opts|
  # Log authentication failures
  request = ActionDispatch::Request.new(env)

  Rails.logger.warn({
    event: "authentication_failed",
    timestamp: Time.current,
    ip_address: request.remote_ip,
    user_agent: request.user_agent,
    scope: opts[:scope],
    message: opts[:message],
    attempted_path: request.path
  }.to_json)
end

Warden::Manager.before_logout do |user, auth, opts|
  # Log logout events
  Rails.logger.info({
    event: "user_logged_out",
    timestamp: Time.current,
    user_id: user.id,
    user_email: user.email,
    scope: opts[:scope]
  }.to_json)
end
