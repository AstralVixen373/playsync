class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:steam, :twitch]

  has_many :posts, dependent: :destroy
  has_many :messages, dependent: :destroy

  has_many :user_chats, dependent: :destroy
  has_many :chats, through: :user_chats

  has_one_attached :avatar

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      if auth.provider.to_s == "steam"
        user.steamid = auth.uid
        user.email = "#{auth.uid}@steam.com" # Steam ne retourne pas d'email; donc on le crée nous même via le uid.
      elsif auth.provider.to_s == "twitch"
        user.twitchid = auth.uid
        user.email = "#{auth.uid}@twitch.com"
      end
      user.password = Devise.friendly_token[0, 20]
    end.tap(&:save!)
  end

  # Saved filter preferences pre-fill the search and the new-post form.
  # Multi-selects submit a blank entry, so strip blanks before saving.
  before_validation :clean_filter_preferences

  # The games behind the saved preferred_game_ids (for displaying chips).
  def preferred_games
    return Game.none if preferred_game_ids.blank?

    Game.where(id: preferred_game_ids)
  end

  private

  def clean_filter_preferences
    self.preferred_platforms  = Array(preferred_platforms).reject(&:blank?)
    self.preferred_post_types = Array(preferred_post_types).reject(&:blank?)
    self.preferred_game_ids   = Array(preferred_game_ids).reject(&:blank?).map(&:to_i)
  end
end
