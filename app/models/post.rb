class Post < ApplicationRecord
  PLATFORMS = ["PC", "PS5", "Xbox", "Nintendo Switch", "Mobile"]
  LANGUAGES = ["English", "French", "Spanish", "German", "Other"]
  TYPES = ["Chill", "Fun", "Competitive"]
  validates :title, presence: true
  validates :platform, presence: true, inclusion: { in: PLATFORMS }
  validates :post_type, presence: true, inclusion: { in: TYPES }
  validates :language, presence: true, inclusion: { in: LANGUAGES }

  belongs_to :user
  belongs_to :game
  has_one :chat, dependent: :destroy

  scope :by_platform, ->(platform) { where(platform: platform) if platform.present? }
  scope :by_game, ->(game) { where("game ILIKE ?", "%#{game}%") if game.present? }
  scope :by_type,     ->(type)     { where(post_type: type) if type.present? }
  scope :by_language, ->(language) { where(language: language) if language.present? }
end
