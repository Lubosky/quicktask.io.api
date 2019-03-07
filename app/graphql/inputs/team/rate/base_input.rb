module Inputs
  module Team
    module Rate
      BaseInput = GraphQL::InputObjectType.define do
        name 'TeamRateBaseInput'
        description ''

        argument :ownerId, types.ID, as: :owner_id

        argument :sourceLanguageId, types.ID, as: :source_language_id
        argument :targetLanguageId, types.ID, as: :target_language_id
        argument :taskTypeId, types.ID, as: :task_type_id
        argument :unitId, types.ID, as: :unit_id

        argument :price, !Types::BigDecimalType
      end
    end
  end
end
