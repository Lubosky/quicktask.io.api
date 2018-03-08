ApplicationSchema = GraphQL::Schema.define do
  resolve_type ->(_type, root, _context) {
    "Types::#{root.model_name}Type".safe_constantize
  }

  # Last Instrumenter is executed as first, so ensure correct order
  instrument(:field, Instrumenters::ErrorInstrumenter.new)
  instrument(:field, GraphQL::Pundit::Instrumenter.new)
  instrument(:field, Instrumenters::NotFoundUnlessInstrumenter.new)
  instrument(:field, Instrumenters::ResourceInstrumenter.new)

  mutation(Types::MutationType)
  query(Types::QueryType)

  use GraphQL::Batch
end
