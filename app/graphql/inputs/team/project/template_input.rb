module Inputs
  module Team
    module Project
      TemplateInput = GraphQL::InputObjectType.define do
        name 'TeamProjectTemplateInput'
        description ''

        argument :templateName, types.String, as: :template_name
        argument :templateDescription, types.String
        argument :workflowType, Types::WorkflowType, as: :template_description
        argument :description, types.String
        argument :identifier, types.String
        argument :internal, types.Boolean
      end
    end
  end
end
