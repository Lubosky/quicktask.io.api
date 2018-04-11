module Inputs
  module Team
    module Project
      StatusInput = GraphQL::InputObjectType.define do
        name 'TeamProjectStatusInput'
        description ''

        argument :status, Types::ProjectStatusType, ''
      end
    end
  end
end
