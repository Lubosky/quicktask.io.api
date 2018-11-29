module Inputs
  module Team
    module Note
      BaseInput = GraphQL::InputObjectType.define do
        name 'NoteBaseInput'
        description ''

        argument :content, types.String
      end
    end
  end
end
