Rails.application.routes.draw do
  root to: "posts#index"
  devise_for :users,
      controllers: {
         omniauth_callbacks: 'users/omniauth_callbacks'
      }
  resources :posts do
    resources :chats, only: [:new, :create]
  end

  resources :chats, only: [:new, :create, :update, :show] do
    resources :messages, only: [:new, :create]
  end

  # resources :user_chats, only: [] do
  #   resources :chats, only: [:create]
  # end

  get "my_matches", to: "matches#index"
  get "my_matches/:id", to: "matches#show", as: "my_match"

  get "up" => "rails/health#show", as: :rails_health_check
end
