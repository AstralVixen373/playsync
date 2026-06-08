class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:steam]

  has_many :posts, dependent: :destroy
  has_many :messages, dependent: :destroy

  has_many :user_chats, dependent: :destroy
  has_many :chats, through: :user_chats

  has_one_attached :avatar

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email      = auth.info.email
      user.password   = Devise.friendly_token[0, 20]
      user.avatar_url = auth.info.image
    end.tap(&:save!)
  end
end
