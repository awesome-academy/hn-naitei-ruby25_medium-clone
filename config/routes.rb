require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  scope "(:locale)", locale: /en|vi/ do
    devise_for :users, controllers: {
      registrations: "users/registrations"
    }
    get "profiles", to: "profile#index", as: :profiles
    scope "profile/:id", as: "profile" do
      get "/", to: "profile#show", as: ""
      get "/followers", to: "profile#followers", as: "followers"
      get "/following", to: "profile#following", as: "following"
    end
    resources :articles do
      resources :comments, only: [ :create, :edit, :update, :destroy ] do
        member do
          get :new_reply, to: "comments#new_reply"
          post :create_reply, to: "comments#create_reply"
        end
      end
      resources :favorites, only: %i[create destroy]
    end
    scope "notifications" do
      post ":id/read", to: "notifications#read", as: :read_notification
      post "read_all", to: "notifications#mark_read_all", as: :read_all_notifications
    end
    resources :relationships, only: %i[create destroy]
    get "search", to: "static_page#search_result", as: :search
    root "static_page#home"
  end

  namespace :api do
    namespace :v1 do
      resources :profiles, only: [:index, :show] do
        member do
          get :followers
          get :following
        end
      end
      resources :auth do
        collection do
          post :login
          post :register
          get :my_profile
          put :update_profile
          get :refresh_token
          delete :logout
        end
      end
      resources :articles, except: [:new, :edit] do
        resources :comments, only: [:create, :update, :destroy]
        resources :favorites, only: [:create, :destroy]
      end
      resources :relationships, only: [:create, :destroy]
    end
  end
end
