class Post < ApplicationRecord
  PLATFORMS = ["PC", "PS5", "Xbox", "Nintendo Switch", "Mobile"]
  LANGUAGES = ["English", "French", "Spanish", "German", "Other"]
  TYPES = ["Looking for Team", "Looking for Players", "Tournament"]
  validates :title, presence: true
  validates :platform, presence: true, inclusion: { in: PLATFORMS }
  validates :post_type, presence: true, inclusion: { in: TYPES }
  validates :language, presence: true, inclusion: { in: LANGUAGES }
  validates :slot, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  belongs_to :user
  belongs_to :game
  has_one :chat, dependent: :destroy

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

  def full?
    members_count >= capacity
  end

  def member?(other_user)
    return false if other_user.nil?

    chat.present? && chat.users.exists?(other_user.id)
  end
end
