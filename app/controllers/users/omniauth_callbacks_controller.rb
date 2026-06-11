class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: %i[steam twitch failure]

  def failure
    redirect_to edit_user_registration_path, alert: "Failed to link accounts."
  end

  def steam
    if current_user.present?
      link_identity
    else
      user = User.from_omniauth(auth)
      user.save if user.new_record? # Save the user if it's a new record
      if user.present?
        sign_out_all_scopes
        flash[:success] = t 'devise.omniauth_callbacks.success', kind: 'steam', locale: :en
        sign_in user, event: :authentication
        link_identity
      else
        flash[:alert] =
          t 'devise.omniauth_callbacks.failure', kind: 'steam', reason: "#{auth.info.email} is not authorized.", locale: :en
        redirect_to new_user_registration_path
      end
    end
  end

  def twitch
    if current_user.present?
      link_identity
    else
      user = User.from_omniauth(auth)
      user.save if user.new_record? # Save the user if it's a new record
      if user.present?
        sign_out_all_scopes
        flash[:success] = t 'devise.omniauth_callbacks.success', kind: 'twitch', locale: :en
        sign_in user, event: :authentication
        link_identity
      else
        flash[:alert] =
          t 'devise.omniauth_callbacks.failure', kind: 'twitch', reason: "#{auth.info.email} is not authorized.", locale: :en
        redirect_to new_user_registration_path
      end
    end
  end

  protected

  def after_omniauth_failure_path_for(_scope)
    new_user_registration_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || new_user_session_path
  end

  private

  def auth
    @auth ||= request.env['omniauth.auth']
  end

  def link_identity
    # redirect_to new_user_session_path, alert: "Connecte-toi d'abord." and return unless user_signed_in?

    auth = request.env['omniauth.auth']

    existing = Identity.find_by(provider: auth.provider, uid: auth.uid)
    if existing && existing.user != current_user
      redirect_to edit_user_registration_path,
                  alert: "This account #{auth.provider.capitalize} is already linked to another user."
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

    flash[:success] = "Account #{auth.provider.capitalize} successfully linked."
    redirect_to edit_user_registration_path
  end
end
