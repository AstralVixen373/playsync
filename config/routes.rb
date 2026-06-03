Rails.application.routes.draw do
  root to: "pages#home"
  devise_for :users,
      controllers: {
         omniauth_callbacks: 'users/omniauth_callbacks'
      }
  resources :posts do
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

  get "up" => "rails/health#show", as: :rails_health_check
end
