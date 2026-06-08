class Post < ApplicationRecord
  PLATFORMS = ["PC", "PS5", "Xbox", "Nintendo Switch", "Mobile"]
  LANGUAGES = ["English", "French", "Spanish", "German", "Other"]
  TYPES = ["Chill", "Fun", "Competitive"]
  STATUSES = %w[open finished].freeze

  enum :status, { open: "open", finished: "finished" }, prefix: false

  before_create :set_default_status

  # A post can target several platforms (e.g. crossplay), so platforms is an
  # array. The multi-select sends a blank entry, so we strip it out first.
  before_validation :clean_platforms

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :platforms, presence: true
  validate  :platforms_within_allowed_list
  validates :post_type, presence: true, inclusion: { in: TYPES }
  validates :language, presence: true, inclusion: { in: LANGUAGES }
  validates :slot, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  belongs_to :user
  belongs_to :game
  has_one :chat, dependent: :destroy

  # Filtering scopes — each accepts a single value or an array, ignored when blank.
  scope :with_games,     ->(ids)    { where(game_id: ids) if ids.present? }
  scope :with_platforms, ->(values) { where("platforms && ARRAY[?]::varchar[]", Array(values)) if values.present? }
  scope :with_types,     ->(types)  { where(post_type: types) if types.present? }
  scope :for_language,   ->(lang)   { where(language: lang) if lang.present? }
  # Posts that still have at least one free spot (creator counts as 1, so the
  # cap is slot + 1). Posts without a chat yet count as 0 members.
  scope :with_free_slots, lambda {
    left_joins(chat: :user_chats)
      .group("posts.id")
      .having("COUNT(user_chats.id) < COALESCE(posts.slot, 0) + 1")
  }

  # Total players the post can hold: the creator + the requested slots.
  def capacity
    slot.to_i + 1
  end

  # Current number of players in the match (members of the chat).
  def members_count
    chat&.users&.count || 0
  end

  def remaining_slots
    capacity - members_count
  end

  def full?
    members_count >= capacity
  end

  def member?(other_user)
    return false if other_user.nil?

    chat.present? && chat.users.exists?(other_user.id)
  end

  private

  def set_default_status
    self.status ||= "open"
  end

  def clean_platforms
    self.platforms = Array(platforms).reject(&:blank?)
  end

  def platforms_within_allowed_list
    invalid = Array(platforms) - PLATFORMS
    errors.add(:platforms, "contains an invalid value") if invalid.any?
  end
end
