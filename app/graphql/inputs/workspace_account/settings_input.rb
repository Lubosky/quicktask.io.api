module Inputs
  module WorkspaceAccount
    SettingsInput = GraphQL::InputObjectType.define do
      name 'WorkspaceAccountSettingsInput'
      description ''

      argument :projectSortOption, types.String, as: :project_sort_option
      argument :projectViewType, types.String, as: :project_view_type
      argument :taskViewType, types.String, as: :task_view_type
    end
  end
end
