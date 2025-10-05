class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc).page(params[:page]).per(20)
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!
    
    if @notification.action_url.present?
      redirect_to @notification.action_url
    else
      redirect_to notifications_path, notice: "Notification marked as read"
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "All notifications marked as read"
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy
    redirect_to notifications_path, notice: "Notification deleted"
  end
end

