module Inputs
  module Team
    module HandOff
      BaseInput = GraphQL::InputObjectType.define do
        name 'TeamHandOffBaseInput'
        description ''

        argument :assigneeId, types.ID, as: :assignee_id
        argument :assignerId, types.ID, as: :assigner_id
        argument :cancellerId, types.ID, as: :canceller_id
        argument :taskId, types.ID, as: :task_id

        argument :assignment, types.Boolean
        argument :rateApplied, !Types::BigDecimalType, as: :rate_applied
        argument :validThrough, Types::DateTimeType, as: :valid_through
      end
    end
  end
end
