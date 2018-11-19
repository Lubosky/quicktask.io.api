# frozen_string_literal: true

class GraphqlChannel < ApplicationCable::Channel
  def subscribed
    @subscription_ids = []
  end

  def execute(data)
    Rails.logger.info("GraphqlChannel#execute: #{data.inspect}")

    query = data['query']
    variables = ensure_hash(data['variables'])
    operation_name = data['operationName']

    result = ApplicationSchema.execute({
      query: query,
      context: context,
      variables: variables,
      operation_name: operation_name
    })

    payload = {
      result: result.subscription? ? nil : result.to_h,
      more: result.subscription?,
    }

    if result.context[:subscription_id]
      @subscription_ids << context[:subscription_id]
    end

    transmit(payload)
  end

  def unsubscribed
    @subscription_ids.each { |sid|
      ApplicationSchema.subscriptions.delete_subscription(sid)
    }
  end

  private

  def context
    {
      current_user: current_user,
      current_workspace: current_workspace,
      current_account: current_account,
      channel: self,
      request: {
        remote_ip: request.remote_ip,
        host: request.host,
        url: request.url
      }
    }
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

