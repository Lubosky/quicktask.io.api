module Inputs
  module Team
    module Client
      BaseInput = GraphQL::InputObjectType.define do
        name 'TeamClientBaseInput'
        description ''

        argument :name, types.String
        argument :email, types.String
        argument :phone, types.String
        argument :currency, types.String
        argument :tax_number, types.String, as: :taxNumber
      end
    end
  end
end
