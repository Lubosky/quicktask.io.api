class Api::V1::Team::TasklistsController < ApplicationController
  before_action :authenticate_user
  before_action :ensure_workspace
  before_action :ensure_workspace_user
  before_action :load_project, only: [:update, :destroy]
  before_action :load_resource, only: [:update, :destroy]

  deserializable_resource :tasklist, only: [:create, :update]

  def create
    authorize [:team, ::Tasklist]
    run ::Team::Tasklist::Create do |action|
      respond_with_result(action: action)
    end
  end

  def update
    authorize [:team, resource]
    run ::Team::Tasklist::Update, default_inputs.merge(tasklist: resource) do |action|
      respond_with_result(action: action)
    end
  end

  def destroy
    authorize [:team, resource]
    run ::Team::Tasklist::Destroy, context: context, tasklist: resource do |action|
      respond_with_result(action: action)
    end
  end

  private

  def accessible_records
    collection = policy_scope([:team, resource_class])
  end

  def resource_class
    @project.tasklists
  end

  def load_project
    @project ||= current_workspace.projects.find(params[:project_id])
  end
end
