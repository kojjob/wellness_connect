class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # CSRF protection with exception on failure
  # Raises ActionController::InvalidAuthenticityToken on CSRF mismatch
  protect_from_forgery with: :exception, prepend: true

  # Use per-form CSRF tokens for enhanced security
  # Each form gets a unique token, preventing token reuse attacks
  self.per_form_csrf_tokens = true

  # Verify Origin header matches Host header for CSRF protection
  # Additional layer of defense against CSRF attacks
  self.forgery_protection_origin_check = true

  # Pundit authorization
  include Pundit::Authorization

  # Security logging for all controller actions
  include SecurityLogger

  # Ensure user is authenticated with Devise
  before_action :authenticate_user!

  # Configure permitted parameters for Devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Rescue from Pundit authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    # Permit additional parameters for sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :role ])

    # Permit additional parameters for account update
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :role ])
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to access this page."
    redirect_to(request.referrer || root_path)
  end
end
