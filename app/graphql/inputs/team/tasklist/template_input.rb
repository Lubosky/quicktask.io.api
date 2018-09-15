module Inputs
  module Team
    module Tasklist
      TemplateInput = GraphQL::InputObjectType.define do
        name 'TeamTasklistTemplateInput'
        description ''

        argument :projectTemplateId, types.ID, as: :project_template_id

        argument :title, types.String
        argument :position, types.Int
      end
    end
  end
end
