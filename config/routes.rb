Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    devise_for :users, controllers: {
      registrations: "users/registrations"
    }
    root "static_page#home"
  end
end
