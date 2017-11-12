require 'constraints/api.rb'

Rails.application.routes.draw do
  namespace :api, defaults: { format: :json }, constraints: { subdomain: 'backend' } do
    scope module: :v1, constraints: Constraints::API.new(version: 1, default: true) do

      resources :users, only: [:index] do
        get :me, on: :collection
      end

      scope path: ':workspace_identifier', as: :workspace, constraints: Constraints::WorkspaceSlug.new do
        resource :membership, only: [:create], path: 'subscribe'

        resource :workspace, only: [:show], path: 'workspace'

        namespace '/v', module: :contractor, as: :contractor do
        end

        namespace '/c', module: :client, as: :client do
        end

        namespace '/t', module: :team, as: :team do
        end
      end
    end

    namespace :auth do
      resource :signup, only: [:create]

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
