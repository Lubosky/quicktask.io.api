module Inputs
  module Team
    module Project
      BaseInput = GraphQL::InputObjectType.define do
        name 'TeamProjectBaseInput'
        description ''

        argument :clientId, types.ID, as: :client_id
        argument :projectGroupId, types.ID, as: :project_group_id

        argument :name, types.String
        argument :description, types.String
        argument :identifier, types.String
        argument :startDate, Types::DateTimeType, as: :start_date
        argument :dueDate, Types::DateTimeType, as: :due_date
        argument :completedDate, Types::DateTimeType, as: :completed_date
        argument :internal, types.Boolean
        argument :templateId, types.ID, as: :template_id
      end
    end
  end
end
