class UserChat < ApplicationRecord
  belongs_to :user
  belongs_to :chat

  after_create_commit :broadcast_append_to_user_chat
  after_destroy_commit :broadcast_remove_to_user_chat

  private

  def broadcast_append_to_user_chat
    broadcast_append_to "user_chat", target: "chat_users", partial: "posts/chat_user", locals: { user: user, post: chat.post }
    update_players_slot
  end

  def broadcast_remove_to_user_chat
    broadcast_remove_to "user_chat", target: "user_#{user.id}"
    update_players_slot
  end

  def update_players_slot
    broadcast_update_to "user_chat", target: "post_#{chat.post.id}_slots", html: "<strong>#{chat.post.members_count}/#{chat.post.capacity}</strong> players"
  end
end
