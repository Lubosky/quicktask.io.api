class Api::V1::Team::QuotesController < Api::V1::Team::ApplicationController
  before_action :authenticate_user
  before_action :ensure_workspace
  before_action :ensure_workspace_account

  def index
    options = {}
    collection = accessible_records.results
    options[:meta] = meta
    render json: Elastic::QuoteSerializer.new(collection, options).serialized_json
  end

  private

  def accessible_records
    @accessible_records ||=
      Finders::QuoteFinder.new(
        user: current_entity,
        workspace: current_workspace,
        filters: filters,
        options: options
      ).execute
  end

  def current_entity
    @current_entity ||= current_account.profile
  end

  def meta
    @meta ||= Finders::QuoteMeta.new(accessible_records, true).call
  end

  def filters
    query = JSON.parse params[:filters]
    query.transform_keys!(&:underscore)
  end

  def options
    query = JSON.parse params[:options]
    query.transform_keys!(&:underscore)
  end


  def resource_class
    current_workspace.tasks
  end

  def resource_serializer
    ::QuoteSerializer
  end
end
