module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags "ActionCable", "User #{current_user.id}"
    end

    private

    def find_verified_user
      # Use Devise's warden to find the authenticated user
      # This works with the session cookie from the browser
      if verified_user = env["warden"]&.user
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
