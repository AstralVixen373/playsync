class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[steam twitch]

  has_many :posts, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :favourites, dependent: :destroy
  has_many :favourite_posts, through: :favourites, source: :post

  has_many :user_chats, dependent: :destroy
  has_many :chats, through: :user_chats
  has_many :identities, dependent: :destroy

  has_one_attached :avatar

  # Virtual flag set by the profile form's "Remove" avatar button. When "1" and
  # no new file is being uploaded, the existing avatar is purged on save.
  attr_accessor :remove_avatar
  before_save :purge_avatar_if_requested

  # Saved filter preferences pre-fill the search and the new-post form.
  # Multi-selects submit a blank entry, so strip blanks before saving.
  before_validation :clean_filter_preferences

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      if auth.provider.to_s == "steam"
        user.email = "#{auth.uid}@steam.com" # Steam ne return pas de d'email; donc on le crée nous même via le uid Steam.
      elsif auth.provider.to_s == "twitch"
        user.email = "#{auth.uid}@twitch.com" # De même pour twitch.
      end
      user.password = Devise.friendly_token[0, 20]
    end.tap(&:save!)
  end

  # The games behind the saved preferred_game_ids (for displaying chips).
  def preferred_games
    return Game.none if preferred_game_ids.blank?

    Game.where(id: preferred_game_ids)
  end

  # The user's hand-entered username/ID for a given platform (e.g. Xbox
  # Gamertag, PSN ID), or nil when not set.
  def platform_handle(platform)
    (platform_handles || {})[platform].presence
  end

  private

  def purge_avatar_if_requested
    return unless ActiveModel::Type::Boolean.new.cast(remove_avatar)
    # A freshly uploaded file (attachment_changes) takes precedence over removal.
    return if attachment_changes.key?("avatar")

    avatar.purge_later if avatar.attached?
  end

  def clean_filter_preferences
    self.preferred_platforms = Array(preferred_platforms).reject(&:blank?)
    self.preferred_post_types = Array(preferred_post_types).reject(&:blank?)
    self.preferred_game_ids = Array(preferred_game_ids).reject(&:blank?).map(&:to_i)

    # Keep only known platforms, trim whitespace, drop blanks.
    self.platform_handles = (platform_handles || {})
      .slice(*Post::PLATFORMS)
      .transform_values { |v| v.to_s.strip }
      .reject { |_, v| v.blank? }
  end
end
