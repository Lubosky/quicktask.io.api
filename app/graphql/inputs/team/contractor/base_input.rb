module Inputs
  module Team
    module Contractor
      BaseInput = GraphQL::InputObjectType.define do
        name 'TeamContractorBaseInput'
        description ''

        argument :firstName, types.String, as: :first_name
        argument :lastName, types.String, as: :last_name
        argument :businessName, types.String, as: :business_name
        argument :email, types.String
        argument :phone, types.String
        argument :currency, types.String
      end
    end
  end
end
