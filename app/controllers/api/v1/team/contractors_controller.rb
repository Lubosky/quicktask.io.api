class Api::V1::Team::ContractorsController < Api::V1::Team::ApplicationController
  before_action :authenticate_user
  before_action :ensure_workspace
  before_action :ensure_workspace_user
  before_action :load_resource, only: [:show, :update, :destroy]

  deserializable_resource :contractor, only: [:create, :update]

  def show
    authorize [:team, resource]
    respond_with_resource
  end

  def create
    authorize [:team, ::Contractor]
    run ::Team::Contractor::Create do |action|
      respond_with_result(action: action)
    end
  end

  def update
    authorize [:team, resource]
    run ::Team::Contractor::Update, default_inputs.merge(contractor: resource) do |action|
      respond_with_result(action: action)
    end
  end

  def destroy
    authorize [:team, resource]
    run ::Team::Contractor::Destroy, context: context, contractor: resource do |action|
      respond_with_result(action: action)
    end
  end

  private

  def accessible_records
    collection = policy_scope([:team, resource_class])
  end

  def resource_class
    current_workspace.contractors
  end
end
