# frozen_string_literal: true

module Instrumenters
  class CamelizeNameInstrumenter
    def instrument(type, field)
      field.property = field.name.underscore.to_sym if field.resolve_proc.is_a?(GraphQL::Field::Resolve::NameResolve)
      field.name = field.name.camelize(:lower)

      field.arguments = Hash[
        field.arguments.map do |name, argument|
          argument.as = argument.name.underscore
          argument.name = argument.name.camelize(:lower)
          [argument.name, argument]
        end
      ]

      field
    end
  end
end
