module Api
  class GraphqlController < ApplicationController
    def execute
      if params[:query]
        variables = ensure_hash(params[:variables])
        operation_name = params[:operationName]
        result = ApplicationSchema.execute(
          query: params[:query],
          variables: variables,
          context: context,
          operation_name: operation_name
        )
      else
        result = ApplicationSchema.multiplex(
          queries
        )
      end
      render json: result
    end

    private

    def context
      {
        current_user: current_user,
        current_workspace: current_workspace,
        current_workspace_user: current_workspace_user,
        request: {
          remote_ip: request.remote_ip,
          host: request.host,
          url: request.url
        }
      }
    end

    def queries
      params.permit(_json: [:query, :operationName, { variables: {} }]).
        to_hash['_json'].map do |query|
          query.transform_keys do |k|
            k.underscore.to_sym
          end.merge(context: context)
        end
    end

    def ensure_hash(ambiguous_param)
      case ambiguous_param
      when String
        if ambiguous_param.present?
          ensure_hash(JSON.parse(ambiguous_param))
        else
          {}
        end
      when Hash, ActionController::Parameters
        ambiguous_param
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
      end
    end
  end
end
