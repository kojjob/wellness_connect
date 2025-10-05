# frozen_string_literal: true

# Security logging concern for tracking security-related events
# Logs authentication attempts, authorization failures, and suspicious activity

module SecurityLogger
  extend ActiveSupport::Concern

  included do
    # Log security events for all controller actions
    after_action :log_security_event, if: :should_log_security_event?
  end

  private

  def log_security_event
    return unless current_user || security_relevant_action?

    Rails.logger.info({
      event: "security_event",
      timestamp: Time.current,
      user_id: current_user&.id,
      user_email: current_user&.email,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      controller: controller_name,
      action: action_name,
      params: filtered_params,
      referer: request.referer
    }.to_json)
  end

  def should_log_security_event?
    # Log security-relevant actions
    security_relevant_action? ||
      authentication_action? ||
      authorization_failed?
  end

  def security_relevant_action?
    # Actions that should always be logged
    %w[
      create destroy update
      login logout sign_in sign_out sign_up
      password reset unlock
    ].include?(action_name)
  end

  def authentication_action?
    # Devise authentication controllers
    devise_controller? ||
      controller_name == "sessions" ||
      controller_name == "registrations" ||
      controller_name == "passwords"
  end

  def authorization_failed?
    # Check if authorization error occurred (Pundit)
    response.status == 403 || response.status == 401
  end

  def filtered_params
    # Remove sensitive data from logged params
    params.except(:password, :password_confirmation, :current_password, :authenticity_token)
          .to_unsafe_h
          .slice(:id, :user_id, :email, :role, :action, :controller)
  end
end
