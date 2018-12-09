class Api::V1::Team::DashboardController < Api::V1::Team::ApplicationController
  before_action :authenticate_user
  before_action :ensure_workspace
  before_action :ensure_workspace_account

  def index
    collection = accessible_records.results
    options = {}
    options[:meta] = aggregations
    render json: ::TaskSerializer.new(collection, options).serialized_json
  end

  private

  def accessible_records
    @accessible_records ||=
      Dashboard::TaskFinder.new(
        user: current_entity,
        workspace: current_workspace,
        filters: filters,
        options: {
          limit: 50,
          page: params[:page]
        }
      ).execute
  end

  def current_entity
    @current_entity ||= current_account.account
  end

  def aggregations
    @aggregations ||= Dashboard::TaskMeta.new(accessible_records).call
  end

  def filters
    params[:filters].to_unsafe_h
  end

  def resource_class
    current_workspace.tasks
  end

  def resource_serializer
    ::TaskSerializer
  end
end
