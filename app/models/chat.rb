class Chat < ApplicationRecord
  belongs_to :post

  has_many :messages, dependent: :destroy

  has_many :user_chats, dependent: :destroy
  has_many :users, through: :user_chats
end
