Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    devise_for :users, controllers: {
      registrations: "users/registrations"
    }
    get "profile/:id", to: "profile#show", as: "profile"
    resources :articles do
      resources :comments, only: [ :create, :edit, :update, :destroy ]
    end
    root "static_page#home"
  end
end
