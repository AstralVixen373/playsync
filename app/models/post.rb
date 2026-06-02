class Post < ApplicationRecord
  validates :title, presence: true
  validates :platform, presence: true
  validates :type, presence: true
  validates :game, presence: true
  validates :language, presence: true

  belongs_to :user
  has_one :chat, dependent: :destroy
end
