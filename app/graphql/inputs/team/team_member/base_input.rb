module Inputs
  module Team
    module TeamMember
      BaseInput = GraphQL::InputObjectType.define do
        name 'TeamMemberBaseInput'
        description ''

        argument :firstName, types.String, as: :first_name
        argument :lastName, types.String, as: :last_name
        argument :email, types.String
        argument :title, types.String
      end
    end
  end
end
