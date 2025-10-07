class NotificationPreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_preference_exists

  def edit
    @preference = current_user.notification_preference
  end

  def update
    @preference = current_user.notification_preference

    if @preference.update(preference_params)
      redirect_to edit_notification_preferences_path, notice: "Notification preferences successfully updated."
    else
      flash.now[:alert] = "There was an error updating your preferences. Please try again."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def preference_params
    params.require(:notification_preference).permit(
      :email_appointments,
      :email_messages,
      :email_payments,
      :email_system,
      :in_app_appointments,
      :in_app_messages,
      :in_app_payments,
      :in_app_system
    )
  end

  def ensure_preference_exists
    current_user.create_notification_preference! unless current_user.notification_preference.present?
  end
end

