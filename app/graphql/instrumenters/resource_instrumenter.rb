# frozen_string_literal: true

# Allows specifying a `resource` proc on fields, whose result will be passed
# to the field's resolve function as the first argument.
#
# Authorization should be performed after this step, so the object can be
# properly authorized.
module Instrumenters
  class ResourceInstrumenter
    def instrument(_type, field)
      old_resolve = field.resolve_proc
      resource_meta = field.metadata[:resource]
      return field unless resource_meta

      resource_proc = resource_meta[:proc]
      new_resolve = resolve_proc(old_resolve,
                                 resource_proc,
                                 resource_meta[:raise_on_nil],
                                 resource_meta[:pass_through])
      field.redefine { resolve new_resolve }
    end

    protected

    def resolve_proc(old_resolve, resource_proc, raise_on_nil, pass_through)
      ->(obj, args, ctx) {
        resource = resource_proc.call(obj, args, ctx)
        if resource || pass_through
          old_resolve.call(resource, args, ctx)
        elsif raise_on_nil
          ctx.add_error(GraphQL::ExecutionError.new('Record Not Found'))
        end
      }
    end
  end

  def self.assign_resource(raise_on_nil)
    ->(definition, proc, pass_through: false) {
      opts = {
        pass_through: pass_through,
        proc: proc,
        raise_on_nil: raise_on_nil
      }
      GraphQL::Define::InstanceDefinable::AssignMetadataKey.new(:resource).
        call(definition, opts)
    }
  end
end

GraphQL::Field.accepts_definitions(
  resource: Instrumenters.assign_resource(false),
  resource!: Instrumenters.assign_resource(true)
)
