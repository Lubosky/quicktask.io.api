module Api
  class BaseController < ApplicationController
    use JSONAPI::ExceptionsHandler

    rescue_from JSON::ParserError do |e|
      logger.error e.inspect
      head :bad_request
    end

    include Interactor
    include JsonapiController
    include Pundit
    include ZanpakutoController

    rescue_from(ActionController::UnpermittedParameters) { |e| respond_with_standard_error e, 400 }
    rescue_from(ActionController::ParameterMissing)      { |e| respond_with_standard_error e, 400 }
    rescue_from(ActionController::RoutingError)          { |e| respond_with_standard_error e, 404 }
    rescue_from(ActiveRecord::RecordNotFound)            { |e| respond_with_standard_error e, 404 }

    rescue_from NotAuthorizedError do |e|
      serializable_error = SerializableError.create(status: 403, title: 'Unauthorized', detail: e.message)
      render jsonapi_errors: [serializable_error].map(&:as_jsonapi), status: 403
    end

    class << self
      private

      def deserializable_resource(key, options = {}, &block)
        super
        define_method :attributes do
          params.fetch(key, {})
        end
      end
    end

    protected

    def append_info_to_payload(payload)
      super
      payload[:host] = request.host
      payload[:remote_ip] = request.remote_ip
      payload[:request_id] = request.uuid
      payload[:user_agent] = request.user_agent
      payload[:user_id] = current_user.uuid if current_user
    end
  end
end
