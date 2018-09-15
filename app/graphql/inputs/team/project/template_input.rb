module Inputs
  module Team
    module Project
      TemplateInput = GraphQL::InputObjectType.define do
        name 'TeamProjectTemplateInput'
        description ''

        argument :templateName, types.String, as: :template_name
        argument :templateDescription, types.String, as: :template_description
        argument :description, types.String
        argument :identifier, types.String
        argument :internal, types.Boolean
        argument :automatedWorkflow, types.Boolean, as: :automated_workflow
      end
    end
  end
end
