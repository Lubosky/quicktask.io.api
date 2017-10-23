module JsonapiController
  extend ActiveSupport::Concern

  included do
    before_action :validate_filter_params

    class_attribute :_pagination, :_sorting, instance_writer: false
    self._pagination = {}.with_indifferent_access
    self._sorting = {}.with_indifferent_access

    filter :or, type: :hash do |controller, scope, value|
      or_filters = value.to_h.symbolize_keys
      base_class = scope.base_class
      primary_key = base_class.primary_key
      base_scope = controller.send(:apply_scopes, base_class, [or_filters.shift].to_h)
      or_scope = base_class.where(primary_key => base_scope)
      or_filters.each do |k, v|
        sub_scope = controller.send(:apply_scopes, base_class, k => v)
        or_scope = or_scope.or(base_class.where(primary_key => sub_scope))
      end
      scope.merge(or_scope)
    end
  end

  module ClassMethods
    def pagination(options = {})
      options.slice!(:limit)
      self._pagination = _pagination.dup
      _pagination.merge!(options)
    end

    def filter(name, options = {}, &block)
      has_scope name, options, &block
    end

    def sort(name, body = nil)
      if body && !body.respond_to?(:call)
        raise ArgumentError, 'The scope body needs to be callable.'
      end
      body ||= ->(direction) { order(name => direction) }
      _sorting[name] = body
    end
  end

  private

  def meta
    @meta ||= {}.with_indifferent_access
  end

  def apply_filtering(scope, hash = filter_params)
    return scope if hash.blank?
    apply_scopes(scope, hash)
  end

  def filter_params
    @filter_params ||= params.fetch(:filter, {}).to_unsafe_h.deep_symbolize_keys
  end

  def validate_filter_params
    allowed_keys = scopes_configuration.map { |_k, v| v[:as] }
    not_allowed_keys = filter_params.keys - allowed_keys
    not_allowed_or_keys = filter_params.fetch(:or, {}).keys - allowed_keys
    not_allowed_keys << { or: not_allowed_or_keys } if not_allowed_or_keys.any?
    bad_request("Filters #{not_allowed_keys.to_json.to_s.tr('"{}', '')} not allowed") if not_allowed_keys.any?
  end

  def apply_pagination(scope, hash = pagination_params)
    return scope if hash.blank?
    total_count = scope.count
    total_count = total_count.count if total_count.is_a?(Hash)
    limit = hash[:limit]
    offset = hash[:offset]
    meta.merge!(limit: limit, offset: offset, total_count: total_count)
    scope.limit(limit).offset(offset)
  end

  def pagination_params
    params.fetch(:page, {}).to_unsafe_h.tap do |h|
      h[:limit] = [h[:limit], _pagination[:limit]].compact.map(&:to_i).min
      h[:offset] = h.fetch(:offset, 0).to_i
    end.compact
  end

  def apply_sorting(scope, hash = sorting_params)
    return scope if hash.blank?
    sorting_params.each do |key, direction|
      scope = scope.instance_exec direction, &_sorting[key] if _sorting[key]
    end
    scope
  end

  def sorting_params
    params.fetch(:sort, '').split(',').map(&:strip).each_with_object({}) do |p, h|
      if p.start_with?('-')
        key = p[1..-1].underscore.to_sym
        h[key] = :desc
      else
        key = p.underscore.to_sym
        h[key] = :asc
      end
    end
  end

  def preload_includes(scope, associations = include_associations)
    scope.preload(associations)
  end

  def include_params
    return [] unless params[:include].is_a?(String)
    params[:include].split(',')
  end

  def include_associations
    include_params.each_with_object([]) do |inc, assocs|
      nest = inc.split('.').map(&:underscore).map(&:to_sym).reverse.reduce { |a, n| { n => a } }
      assocs << nest
    end
  end

  def bad_request(message = 'Bad request')
    status = 400
    data = { errors: { status: status, code: 'bad_request', detail: message } }
    render json: data, status: status
  end
end
