require 'jsonapi/rails/deserializable_resource'
require 'jsonapi/exceptions_handler'

JSONAPI::Rails::DeserializableResource.key_formatter = proc { |k| k.to_s.underscore }

JSONAPI::Rails.configure do |config|
  # # Set a default serializable class mapping.
  # config.jsonapi_class = Hash.new { |h, k|
  #   names = k.to_s.split('::')
  #   klass = names.pop
  #   h[k] = [*names, "Serializable#{klass}"].join('::').safe_constantize
  # }

  # # Set a default serializable class mapping for errors.
  # config.jsonapi_errors_class = Hash.new { |h, k|
  #   names = k.to_s.split('::')
  #   klass = names.pop
  #   h[k] = [*names, "Serializable#{klass}"].join('::').safe_constantize
  # }.tap { |h|
  #   h[:'ActiveModel::Errors'] = JSONAPI::Rails::SerializableActiveModelErrors
  #   h[:Hash] = JSONAPI::Rails::SerializableErrorHash
  # }

  # # Set a default JSON API object.
  config.jsonapi_object = ->() { nil }

  # # Set default exposures.
  # # A lambda/proc that will be eval'd in the controller context.
  # config.jsonapi_expose = lambda {
  #   { url_helpers: ::Rails.application.routes.url_helpers }
  # }

  # # Set default fields.
  # # A lambda/proc that will be eval'd in the controller context.
  # config.jsonapi_fields = ->() { nil }

  # # Uncomment the following to have it default to the `fields` query
  # #   parameter.
  # config.jsonapi_fields = lambda {
  #   fields_param = params.to_unsafe_hash.fetch(:fields, {})
  #   Hash[fields_param.map { |k, v| [k.to_sym, v.split(',').map!(&:to_sym)] }]
  # }

  # # Set default include.
  # # A lambda/proc that will be eval'd in the controller context.
  # config.jsonapi_include = ->() { nil }

  # # Uncomment the following to have it default to the `include` query
  # # parameter.
  config.jsonapi_include = lambda { params[:include] }

  # # Set default links.
  # # A lambda/proc that will be eval'd in the controller context.
  # config.jsonapi_links = ->() { {} }

  # # Set a default pagination scheme.
  # config.jsonapi_pagination = ->(_) { {} }
end
