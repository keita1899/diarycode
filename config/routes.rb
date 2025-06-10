Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"

  # Calendar route
  get "calendar" => "calendar#index"

  # Reports routes
  resources :reports, only: [:new, :create, :edit, :update, :destroy]

  # Templates routes
  resources :templates, only: [:index, :new, :create, :edit, :update, :destroy] do
    member do
      patch :set_default
    end
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
