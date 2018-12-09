class Api::V1::Team::ProjectsController < Api::V1::Team::ApplicationController
  before_action :authenticate_user
  before_action :ensure_workspace
  before_action :ensure_workspace_account
  before_action :load_resource,
                only: [:show, :update, :destroy, :nullify, :prepare, :plan, :activate, :suspend, :complete, :cancel, :archive]

  deserializable_resource :project, only: [:create, :update]

  def show
    authorize [:team, resource]
    respond_with_resource
  end

  def create
    authorize [:team, ::Project]
    run ::Team::Project::Create do |action|
      respond_with_result(action: action)
    end
  end

  def update
    authorize [:team, resource]
    run ::Team::Project::Update, default_inputs.merge(project: resource) do |action|
      respond_with_result(action: action)
    end
  end

  def destroy
    authorize [:team, resource]
    run ::Team::Project::Destroy, context: context, project: resource do |action|
      respond_with_result(action: action)
    end
  end

  def nullify
    authorize [:team, resource], :update?
    run ::Team::Project::Nullify, context: context, project: resource do |action|
      respond_with_result(action: action)
    end
  end

  def prepare
    authorize [:team, resource], :update?
    run ::Team::Project::Prepare, context: context, project: resource do |action|
      respond_with_result(action: action)
    end
  end

  def plan
    authorize [:team, resource], :update?
    run ::Team::Project::Plan, context: context, project: resource do |action|
      respond_with_result(action: action)
    end
  end

  def activate
    authorize [:team, resource], :update?
    run ::Team::Project::Activate, context: context, project: resource do |action|
      respond_with_result(action: action)
    end
  end

  def suspend
    authorize [:team, resource], :update?
    run ::Team::Project::Suspend, context: context, project: resource do |action|
      respond_with_result(action: action)
    end
  end

  def complete
    authorize [:team, resource], :update?
    run ::Team::Project::Complete, context: context, project: resource do |action|
      respond_with_result(action: action)
    end
  end

  def cancel
    authorize [:team, resource], :update?
    run ::Team::Project::Cancel, context: context, project: resource do |action|
      respond_with_result(action: action)
    end
  end

  def archive
    authorize [:team, resource], :update?
    run ::Team::Project::Archive, context: context, project: resource do |action|
      respond_with_result(action: action)
    end
  end

  private

  def accessible_records
    collection = policy_scope([:team, ::Project])
  end

  def resource_class
    Project::Regular
  end
end
