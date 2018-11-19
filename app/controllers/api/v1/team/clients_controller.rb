class Api::V1::Team::ClientsController < Api::V1::Team::ApplicationController
  before_action :authenticate_user
  before_action :ensure_workspace
  before_action :ensure_workspace_account
  before_action :load_resource, only: [:show, :update, :destroy]

  deserializable_resource :client, only: [:create, :update]

  def show
    authorize [:team, resource]
    respond_with_resource
  end

  def create
    authorize [:team, ::Client]
    run ::Team::Client::Create do |action|
      respond_with_result(action: action)
    end
  end

  def update
    authorize [:team, resource]
    run ::Team::Client::Update, default_inputs.merge(client: resource) do |action|
      respond_with_result(action: action)
    end
  end

  def destroy
    authorize [:team, resource]
    run ::Team::Client::Destroy, context: context, client: resource do |action|
      if action.success?
        head(204)
      else
        respond_with_errors(action.errors)
      end
    end
  end

  private

  def accessible_records
    collection = policy_scope([:team, resource_class])
  end

  def resource_class
    current_workspace.clients
  end
end
