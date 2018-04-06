class Api::V1::Team::TodosController < ApplicationController
  before_action :authenticate_user
  before_action :ensure_workspace
  before_action :ensure_workspace_user
  before_action :load_task, only: [:update, :destroy]
  before_action :load_resource, only: [:update, :destroy]

  deserializable_resource :task, only: [:create, :update]

  def show
    authorize [:team, resource]
    respond_with_resource
  end

  def create
    authorize [:team, ::Todo]
    run ::Team::Todo::Create do |action|
      respond_with_result(action: action)
    end
  end

  def update
    authorize [:team, resource]
    run ::Team::Todo::Update, default_inputs.merge(todo: resource) do |action|
      respond_with_result(action: action)
    end
  end

  def destroy
    authorize [:team, resource]
    run ::Team::Todo::Destroy, context: context, todo: resource do |action|
      respond_with_result(action: action)
    end
  end

  private

  def resource_class
    @task.todos
  end

  def load_task
    @task ||= current_workspace.tasks.find(params[:task_id])
  end
end
