module Inputs
  module Team
    module Todo
      BaseInput = GraphQL::InputObjectType.define do
        name 'TeamTodoBaseInput'
        description ''

        argument :assigneeId, types.ID, as: :assignee_id
        argument :taskId, types.ID, as: :task_id

        argument :title, types.String
        argument :dueDate, Types::DateTimeType, as: :due_date
        argument :completedDate, Types::DateTimeType, as: :completed_date
        argument :completed, types.Boolean
        argument :position, types.Int
      end
    end
  end
end
