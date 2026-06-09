class SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def update_email
    if current_user.update(email: params[:user][:email])
      redirect_to settings_path, notice: t("settings.notices.email_updated", locale: :en)
    else
      redirect_to settings_path, alert: I18n.with_locale(:en) { current_user.errors.full_messages.join(", ") }
    end
  end

  def update_language
    language = params[:language].to_s
    if %w[English French Spanish German].include?(language)
      current_user.update!(preferred_language: language)
    end
    redirect_to settings_path
  end

  def update_password
    unless current_user.valid_password?(params[:user][:current_password])
      return redirect_to settings_path, alert: t("settings.notices.password_incorrect", locale: :en)
    end

    if current_user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
      bypass_sign_in(current_user)
      redirect_to settings_path, notice: t("settings.notices.password_updated", locale: :en)
    else
      redirect_to settings_path, alert: I18n.with_locale(:en) { current_user.errors.full_messages.join(", ") }
    end
  end
end
