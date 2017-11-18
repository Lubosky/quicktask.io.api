module Interactor
  extend ActiveSupport::Concern

  included {}

  private

  def run(interaction_class, inputs = default_inputs)
    interaction = interaction_class.run(inputs)
    return interaction unless block_given?
    yield(interaction)
  end

  def default_inputs
    {}.tap do |h|
      h.merge!(attributes.to_unsafe_h)
      h[:context] = context
    end
  end

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
end
