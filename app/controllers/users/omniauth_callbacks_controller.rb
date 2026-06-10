class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: %i[steam twitch failure]

  def failure
    redirect_to edit_user_registration_path, alert: "Échec de la liaison du compte."
  end

  def steam = link_identity

  def twitch = link_identity

  private

  def link_identity
    redirect_to new_user_session_path, alert: "Connecte-toi d'abord." and return unless user_signed_in?

    auth = request.env['omniauth.auth']

    existing = Identity.find_by(provider: auth.provider, uid: auth.uid)
    if existing && existing.user != current_user
      redirect_to edit_user_registration_path,
                  alert: "Ce compte #{auth.provider.capitalize} est déjà lié à un autre utilisateur."
      return
    end

    identity = current_user.identities.find_or_initialize_by(
      provider: auth.provider, uid: auth.uid
    )
    identity.update(
      token: auth.credentials&.token,
      refresh_token: auth.credentials&.refresh_token,
      nickname: auth.info.nickname,
      image: auth.info.image
    )

    flash[:success] = "Compte #{auth.provider.capitalize} lié."
    redirect_to edit_user_registration_path
  end
end
