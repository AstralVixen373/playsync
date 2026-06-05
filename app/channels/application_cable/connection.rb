module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Devise stores the authenticated user in the Warden middleware, which is
      # also available to the Action Cable connection. We reuse it so the voice
      # signaling channel can authorize members exactly like the rest of the app.
      env["warden"]&.user || reject_unauthorized_connection
    end
  end
end
