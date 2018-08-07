module Inputs
  module Team
    module Task
      BaseInput = GraphQL::InputObjectType.define do
        name 'TeamTaskBaseInput'
        description ''

        argument :ownerId, types.ID, as: :owner_id
        argument :projectId, types.ID, as: :project_id
        argument :tasklistId, types.ID, as: :tasklist_id

        argument :sourceLanguageId, types.ID, as: :source_language_id
        argument :targetLanguageId, types.ID, as: :target_language_id
        argument :taskTypeId, types.ID, as: :task_type_id
        argument :unitId, types.ID, as: :unit_id

        argument :title, types.String
        argument :description, types.String
        argument :color, types.String
        argument :startDate, Types::DateTimeType, as: :start_date
        argument :dueDate, Types::DateTimeType, as: :due_date
        argument :completedDate, Types::DateTimeType, as: :completed_date
        argument :unitCount, types.Float, as: :unit_count
        argument :completedUnitCount, types.Float, as: :completed_unit_count
        argument :position, types.Int
      end
    end
  end
end
