# config/routes.rb
Rails.application.routes.draw do
  resources :posts, only: [:index, :new, :create]
  root 'posts#index'
end
