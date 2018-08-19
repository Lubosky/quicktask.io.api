module Inputs
  module Team
    module HandOff
      ActionInput = GraphQL::InputObjectType.define do
        name 'TeamHandOffActionInput'
        description ''

        argument :action, Types::HandOffActionType, ''
      end
    end
  end
end
