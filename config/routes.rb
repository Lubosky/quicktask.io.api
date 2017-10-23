require 'constraints/api.rb'

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json }, constraints: { subdomain: 'backend' } do
    scope module: :v1, constraints: Constraints::API.new(version: 1, default: true) do
      resources :users, only: [:index, :create] do
        get :me, on: :collection
      end
    end

    namespace :auth do
      post 'login', to: 'token#create'
      delete 'logout', to: 'token#destroy'

      scope :password do
        post 'forgot', to: 'password#forgot'
        get 'reset/:token', to: 'password#verify'
        patch 'reset', to: 'password#reset'
      end
    end

    namespace :oauth do
      post 'google', to: 'google#create'
    end
  end
end
