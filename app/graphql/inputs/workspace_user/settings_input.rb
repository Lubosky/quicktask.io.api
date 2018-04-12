module Inputs
  module WorkspaceUser
    SettingsInput = GraphQL::InputObjectType.define do
      name 'WorkspaceUserSettingsInput'
      description ''

      argument :projectViewType, types.String, as: :project_view_type
      argument :taskViewType, types.String, as: :task_view_type
    end
  end
end
