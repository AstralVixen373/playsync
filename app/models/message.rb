class Message < ApplicationRecord
  validates :content, presence: true
  belongs_to :chat
  belongs_to :user

  after_create_commit :broadcast_append_to_chat

  private

  def broadcast_append_to_chat
    broadcast_append_to chat, target: "messages", partial: "messages/message", locals: { message: self, current_user: self.user }
  end
end
