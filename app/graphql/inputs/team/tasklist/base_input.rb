module Inputs
  module Team
    module Tasklist
      BaseInput = GraphQL::InputObjectType.define do
        name 'TeamTasklistBaseInput'
        description ''

        argument :projectId, types.ID, as: :project_id

        argument :title, types.String
        argument :position, types.Int
      end
    end
  end
end
