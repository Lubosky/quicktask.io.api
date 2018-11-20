module Inputs
  module Team
    module Tag
      BaseInput = GraphQL::InputObjectType.define do
        name 'TagBaseInput'
        description ''

        argument :name, types.String
        argument :color, Types::ColorType
      end
    end
  end
end
