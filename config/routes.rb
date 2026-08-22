Rails.application.routes.draw do
  devise_for :users
  root "conversations#index"

  resources :conversations do
    resources :messages, only: %i[create]
  end
end
