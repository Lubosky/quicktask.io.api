class Api::V1::Team::TasksController < ApplicationController
  before_action :authenticate_user
  before_action :ensure_workspace
  before_action :ensure_workspace_user
  before_action :load_project,
                only: [:show, :update, :destroy, :nullify, :prepare, :plan, :activate, :suspend, :complete, :cancel, :archive]
  before_action :load_tasklist,
                only: [:show, :update, :destroy, :nullify, :prepare, :plan, :activate, :suspend, :complete, :cancel, :archive]
  before_action :load_resource,
                only: [:show, :update, :destroy, :nullify, :prepare, :plan, :activate, :suspend, :complete, :cancel, :archive]

  deserializable_resource :task, only: [:create, :update]

  def show
    authorize [:team, resource]
    respond_with_resource
  end

  def create
    authorize [:team, ::Task]
    run ::Team::Task::Create do |action|
      respond_with_result(action: action)
    end
  end

  def update
    authorize [:team, resource]
    run ::Team::Task::Update, default_inputs.merge(task: resource) do |action|
      respond_with_result(action: action)
    end
  end

  def destroy
    authorize [:team, resource]
    run ::Team::Task::Destroy, context: context, task: resource do |action|
      respond_with_result(action: action)
    end
  end

  def nullify
    authorize [:team, resource], :update?
    run ::Team::Task::Nullify, context: context, task: resource do |action|
      respond_with_result(action: action)
    end
  end

  def prepare
    authorize [:team, resource], :update?
    run ::Team::Task::Prepare, context: context, task: resource do |action|
      respond_with_result(action: action)
    end
  end

  def plan
    authorize [:team, resource], :update?
    run ::Team::Task::Plan, context: context, task: resource do |action|
      respond_with_result(action: action)
    end
  end

  def activate
    authorize [:team, resource], :update?
    run ::Team::Task::Activate, context: context, task: resource do |action|
      respond_with_result(action: action)
    end
  end

  def suspend
    authorize [:team, resource], :update?
    run ::Team::Task::suspend, context: context, task: resource do |action|
      respond_with_result(action: action)
    end
  end

  def complete
    authorize [:team, resource], :update?
    run ::Team::Task::Complete, context: context, task: resource do |action|
      respond_with_result(action: action)
    end
  end

  def cancel
    authorize [:team, resource], :update?
    run ::Team::Task::Cancel, context: context, task: resource do |action|
      respond_with_result(action: action)
    end
  end

  def archive
    authorize [:team, resource], :update?
    run ::Team::Task::Archive, context: context, task: resource do |action|
      respond_with_result(action: action)
    end
  end

  private

  def resource_class
    @tasklist.tasks
  end

  def load_project
    @project ||= current_workspace.projects.find(params[:project_id])
  end

  def load_tasklist
    @tasklist ||= @project.tasklists.find(params[:tasklist_id])
  end
end
