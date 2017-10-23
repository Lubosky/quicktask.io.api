module ZanpakutoController
  extend ActiveSupport::Concern

  included {}

  def index
    instantiate_collection
    respond_with_collection
  end

  def show
    respond_with_resource
  end

  def create
    instantiate_resource
    create_action
    respond_with_resource
  end

  def create_action
    resource.save
  end

  def update
    load_resource
    update_action
    respond_with_resource
  end

  def update_action
    resource.update(resource_params)
  end

  def destroy
    load_resource
    destroy_action
    render json: { success: 'success' }
  end

  def destroy_action
    resource.destroy
  end

  private

  def collection
    instance_variable_get :"@#{resource_plural}"
  end

  def resource
    instance_variable_get :"@#{resource_name}"
  end

  def resource=(value)
    instance_variable_set :"@#{resource_name}", value
  end

  def collection=(value)
    instance_variable_set :"@#{resource_name.pluralize}", value
  end

  def instantiate_resource
    self.resource = resource_class.new(resource_params)
  end

  def instantiate_collection(apply_timeframe: true, apply_filtering: true, apply_sorting: true, apply_pagination: true, preload_includes: true)
    collection = accessible_records
    collection = yield collection             if block_given?
    collection = apply_timeframe collection   if apply_timeframe
    collection = apply_filtering collection   if apply_filtering
    collection = apply_sorting collection     if apply_sorting
    collection = apply_pagination collection  if apply_pagination
    collection = preload_includes collection  if preload_includes
    self.collection = collection.to_a
  end

  def apply_timeframe(collection)
    if resource_class.try(:has_timeframe?) && (params[:since] || params[:until])
      parse_date_parameters
      collection.within(params[:since], params[:until], params[:timeframe_for])
    else
      collection
    end
  end

  def parse_date_parameters
    %w(since until).each { |field| params[field] = DateTime.parse(params[field].to_s) if params[field] }
  end

  def accessible_records
    raise NotImplementedError.new
  end

  def load_resource
    self.resource = resource_class.find(params[:id])
  end

  def permitted_params
    @permitted_params ||= PermittedParams.new(params)
  end

  def resource_params
    permitted_params.send resource_name
  end

  def resource_symbol
    resource_name.to_sym
  end

  def resource_name
    controller_name.singularize
  end

  def resource_class
    resource_name.camelize.constantize
  end

  def resource_plural
    controller_name
  end

  def resource_serializer
    jsonapi_class
  end

  def respond_with_result(action: nil, **opts)
    if action.success?
      render jsonapi: action.result,
             class: opts[:serializer] || resource_serializer,
             cache: opts[:cache],
             fields: opts[:fields],
             include: opts[:include],
             meta: opts[:meta],
             relationship: opts[:relationship]
    else
      respond_with_errors(action.errors)
    end
  end

  def respond_with_resource(**opts)
    if resource.errors.empty?
      render jsonapi: resource,
             class: opts[:serializer] || resource_serializer,
             cache: opts[:cache],
             fields: opts[:fields],
             include: opts[:include],
             meta: opts[:meta],
             relationship: opts[:relationship]
    else
      respond_with_errors(resource.errors)
    end
  end

  def respond_with_collection(**opts)
    render jsonapi: collection,
           class: opts[:serializer] || resource_serializer,
           cache: opts[:cache],
           fields: opts[:fields],
           include: opts[:include],
           meta: opts[:meta],
           relationship: opts[:relationship]
  end

  def respond_with_standard_error(error, status)
    serializable_error = SerializableError.create(status: status, detail: error.message)
    render jsonapi_errors: serializable_error.as_jsonapi, status: status
  end

  def respond_with_error(error, status)
    title = I18n.t("errors.#{error}.title")
    detail = I18n.t("errors.#{error}.detail")
    serializable_error = SerializableError.create(status: status, title: title, detail: detail)
    render jsonapi_errors: serializable_error.as_jsonapi, status: status
  end

  def respond_with_errors(errors, status: 422)
    jsonapi_errors = SerializableError.from_activemodel_errors(errors)
    logger.info jsonapi_errors.map(&:as_jsonapi)
    render jsonapi_errors: jsonapi_errors.map(&:as_jsonapi), status: status
  end
end
