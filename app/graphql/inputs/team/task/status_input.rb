module Inputs
  module Team
    module Task
      StatusInput = GraphQL::InputObjectType.define do
        name 'TeamTaskStatusInput'
        description ''

        argument :status, Types::TaskStatusType, ''
      end
    end
  end
end
