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
          "Announcement sent to #{count} users successfully."
        when "patients"
          "Announcement sent to #{count} patients successfully."
        when "providers"
          "Announcement sent to #{count} providers successfully."
        when "specific"
          user = User.find(@announcement.user_id)
          "Announcement sent to #{user.email} successfully."
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
        user = User.find(@announcement.user_id)
        if NotificationService.send(:can_notify?, user, "system_announcement")
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
  end
end

