require 'constraints/api.rb'

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json }, constraints: { subdomain: 'backend' } do
    scope module: :v1, constraints: Constraints::API.new(version: 1, default: true) do

      post :signup, to: 'signup_tokens#create'
      get 'signup/confirm', to: 'signup_tokens#verify'

      resources :users, only: [:create] do
        get :me, on: :collection
      end

      resources :workspaces, only: [:index, :show, :create, :update],
                             param: :identifier do

        resource :membership, only: [:create]

        namespace :v, module: :contractor, as: :contractor do
        end

        namespace :c, module: :client, as: :client do
        end

        namespace :t, module: :team, as: :team do
        end
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
