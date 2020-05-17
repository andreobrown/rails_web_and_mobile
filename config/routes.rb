Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "pages/home"
  get "pages/about"
  root to: "pages#home"
  resources :orders
  devise_for :customers

  namespace :api do
    devise_for :customers, defaults: { format: :json },
                           #class_name: "ApiCustomer",
                           skip: [:registrations, :invitations,
                                  :passwords, :confirmations,
                                  :unlocks],
                           path: "",
                           path_names: { sign_in: "login",
                                         sign_out: "logout" }
    devise_scope :customer do
      get "login", to: "customers/sessions#new"
      delete "logout", to: "customers/sessions#destroy"
    end
  end
end
