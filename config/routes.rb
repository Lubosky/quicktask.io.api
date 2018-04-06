require 'constraints/api.rb'

Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/api/graphql'
  end

  namespace :api, defaults: { format: :json }, constraints: { subdomain: 'backend' } do
    post '/graphql', to: 'graphql#execute'

    scope module: :v1, constraints: Constraints::API.new(version: 1, default: true) do

      resource :env, only: [:show], controller: 'env'
      resource :status, only: [:show], controller: 'status'

      post :signup, to: 'signup_tokens#create'
      get 'signup/confirm', to: 'signup_tokens#verify'

      resources :users, only: [:create] do
        get :me, on: :collection
      end

      resources :workspaces, only: [:index, :show, :create, :update],
                             param: :identifier do

        resource :membership, only: [:create]

        namespace :client, module: :client, as: :client do
        end

        namespace :team, module: :team, as: :team do
          resources :clients
          resources :contractors
          resources :projects do
            [:prepare, :plan, :activate, :suspend, :complete, :cancel, :archive].each do |action|
              post action, on: :member
            end
            resources :tasklists, except: [:show] do
              resources :tasks, except: [:index] do
                [:prepare, :plan, :activate, :suspend, :complete, :cancel, :archive].each do |action|
                  post action, on: :member
                end
                resources :todo, except: [:show] do
                  post :assign, on: :member
                  post :complete, on: :member
                end
              end
            end
          end
        end

        namespace :vendor, module: :vendor, as: :vendor do
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
