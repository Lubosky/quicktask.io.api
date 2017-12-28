ApplicationSchema = GraphQL::Schema.define do
  resolve_type ->(_type, root, _context) {
    "Types::#{root.model_name}Type".safe_constantize
  }

  # The last Instrumenter is executed first, so make sure these are in the
  # correct order
  instrument(:field, GraphQL::Pundit::Instrumenter.new)

  mutation(Types::MutationType)
  query(Types::QueryType)

  use GraphQL::Batch
end
