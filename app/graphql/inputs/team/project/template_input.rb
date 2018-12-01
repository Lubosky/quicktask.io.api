module Inputs
  module Team
    module Project
      TemplateInput = GraphQL::InputObjectType.define do
        name 'TeamProjectTemplateInput'
        description ''

        argument :templateName, types.String, as: :template_name
        argument :templateDescription, types.String, as: :template_description
        argument :workflowType, Types::WorkflowType, as: :workflow_type
        argument :description, types.String
        argument :identifier, types.String
        argument :internal, types.Boolean
      end
    end
  end
end
