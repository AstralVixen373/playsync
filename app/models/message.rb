class Message < ApplicationRecord
  validates :content, presence: true
  belongs_to :chat
  belongs_to :user
end
