Rails.application.routes.draw do
  root to: "posts#index"
  devise_for :users,
      controllers: {
        omniauth_callbacks: 'users/omniauth_callbacks',
        registrations: 'users/registrations'
      }
  resources :posts do
    member do
      post :join
      delete :leave
      patch :finish
      delete :kick
    end
    resources :chats, only: [:new, :create]
  end

  resources :games do
    collection do
      get :search
    end
  end

  resources :chats, only: [:new, :create, :update, :show] do
    resources :messages, only: [:new, :create]
  end

  # resources :user_chats, only: [] do
  #   resources :chats, only: [:create]
  # end

  get "my_matches", to: "matches#index"
  get "my_matches/:id", to: "matches#show", as: "my_match"

  get  "settings",          to: "settings#show",           as: :settings
  patch "settings/email",    to: "settings#update_email",    as: :settings_email
  patch "settings/password", to: "settings#update_password", as: :settings_password
  patch "settings/language", to: "settings#update_language", as: :settings_language

  get "up" => "rails/health#show", as: :rails_health_check
end
