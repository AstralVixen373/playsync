class Post < ApplicationRecord
  PLATFORMS = ["PC", "PS5", "Xbox", "Nintendo Switch", "Mobile"]
  LANGUAGES = ["English", "French", "Spanish", "German", "Other"]
  TYPES = ["Looking for Team", "Looking for Players", "Tournament"]
  validates :title, presence: true
  validates :platform, presence: true, inclusion: { in: PLATFORMS }
  validates :post_type, presence: true, inclusion: { in: TYPES }
  validates :language, presence: true, inclusion: { in: LANGUAGES }

  belongs_to :user
  belongs_to :game
  has_one :chat, dependent: :destroy
end
