# frozen_string_literal: true

# Instrumenter that allows returning 'Record Not Found' based on policies.
class Instrumenters::NotFoundUnlessInstrumenter
  # rubocop:disable Metrics/MethodLength
  def instrument(_type, field)
    query = field.metadata[:not_found_unless]
    return field unless query

    old_resolve = field.resolve_proc
    field.redefine do
      resolve = ->(obj, args, ctx) {
        policy = Pundit.policy!(ctx[:current_user], obj)
        action = `#{query.to_s}?`
        return old_resolve.call(obj, args, ctx) if policy.public_send(action)

        ctx.add_error(GraphQL::ExecutionError.new('Record Not Found'))
        nil
      }
    end
  end
end

GraphQL::Field.accepts_definitions(
  not_found_unless:
    GraphQL::Define::InstanceDefinable::AssignMetadataKey.new(:not_found_unless)
)
