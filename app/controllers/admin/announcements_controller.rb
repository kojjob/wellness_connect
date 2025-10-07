module Admin
  class AnnouncementsController < BaseController
    def new
      @announcement = Announcement.new
    end

    def create
      @announcement = Announcement.new(announcement_params)

      if @announcement.valid?
        count = send_announcement

        flash[:notice] = case @announcement.recipient_type
        when "all"
          if count > 0
            "Announcement sent to #{count} users successfully."
          else
            "No recipients reached. All users have system notifications disabled."
          end
        when "patients"
          if count > 0
            "Announcement sent to #{count} patients successfully."
          else
            "No recipients reached. All patients have system notifications disabled."
          end
        when "providers"
          if count > 0
            "Announcement sent to #{count} providers successfully."
          else
            "No recipients reached. All providers have system notifications disabled."
          end
        when "specific"
          user = @announcement.user
          if user.nil?
            "Error: Selected user no longer exists."
          elsif count > 0
            "Announcement sent to #{user.email} successfully."
          else
            "Announcement not delivered to #{user.email} (notifications disabled)."
          end
        end

        redirect_to admin_root_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def preview
      @announcement = Announcement.new(announcement_params)
      
      respond_to do |format|
        format.turbo_stream
      end
    end

    private

    def announcement_params
      params.require(:announcement).permit(:title, :message, :recipient_type, :user_id)
    end

    def send_announcement
      count = 0

      case @announcement.recipient_type
      when "all"
        User.find_each do |user|
          if NotificationService.send(:can_notify?, user, "system_announcement")
            NotificationService.notify_system_announcement(user, @announcement.title, @announcement.message)
            count += 1
          end
        end
      when "patients"
        User.where(role: "patient").find_each do |user|
          if NotificationService.send(:can_notify?, user, "system_announcement")
            NotificationService.notify_system_announcement(user, @announcement.title, @announcement.message)
            count += 1
          end
        end
      when "providers"
        User.where(role: "provider").find_each do |user|
          if NotificationService.send(:can_notify?, user, "system_announcement")
            NotificationService.notify_system_announcement(user, @announcement.title, @announcement.message)
            count += 1
          end
        end
      when "specific"
        user = @announcement.user
        if user.present? && NotificationService.send(:can_notify?, user, "system_announcement")
          NotificationService.notify_system_announcement(user, @announcement.title, @announcement.message)
          count = 1
        end
      end

      count
    end
  end

  # Form object for announcement
  class Announcement
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :title, :string
    attribute :message, :string
    attribute :recipient_type, :string
    attribute :user_id, :integer

    validates :title, presence: true, length: { maximum: 255 }
    validates :message, presence: true, length: { maximum: 1000 }
    validates :recipient_type, presence: true, inclusion: { in: %w[all patients providers specific] }
    validates :user_id, presence: true, if: -> { recipient_type == "specific" }
    validate :user_must_exist, if: -> { recipient_type == "specific" && user_id.present? }

    def user
      @user ||= User.find_by(id: user_id) if user_id.present?
    end

    private

    def user_must_exist
      if user.nil?
        errors.add(:user_id, "must reference a valid user")
      end
    end
  end
end
