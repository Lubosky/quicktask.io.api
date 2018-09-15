module Inputs
  module Team
    module Task
      TemplateInput = GraphQL::InputObjectType.define do
        name 'TeamTaskTemplateInput'
        description ''

        argument :ownerId, types.ID, as: :owner_id
        argument :projectTemplateId, types.ID, as: :project_template_id
        argument :tasklistId, types.ID, as: :tasklist_id

        argument :sourceLanguageId, types.ID, as: :source_language_id
        argument :targetLanguageId, types.ID, as: :target_language_id
        argument :taskTypeId, types.ID, as: :task_type_id
        argument :unitId, types.ID, as: :unit_id

        argument :title, types.String
        argument :description, types.String
        argument :color, types.String
        argument :unitCount, types.Float, as: :unit_count
        argument :position, types.Int
      end
    end
  end
end
