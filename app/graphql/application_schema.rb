ApplicationSchema = GraphQL::Schema.define do
  resolve_type ->(_type, root, _context) {
    "Types::#{root.model_name}Type".safe_constantize
  }

  # Last Instrumenter is executed as first, so ensure correct order
  instrument(:field, GraphQL::Pundit::Instrumenter.new)
  instrument(:field, Instrumenters::NotFoundUnlessInstrumenter.new)
  instrument(:field, Instrumenters::ResourceInstrumenter.new)
  instrument(:field, Instrumenters::CamelizeNameInstrumenter.new)

  mutation(Types::MutationType)
  query(Types::QueryType)

  use GraphQL::Batch
end

GraphQL::Errors.configure(ApplicationSchema) do
  rescue_from ActiveRecord::RecordNotFound do |exception|
    nil
  end

  rescue_from ActiveRecord::RecordInvalid do |exception|
    exception.record.errors.each do |field, errors|
      errors.each do |message|
        GraphQL::ExecutionError.new("#{field}: #{message}")
      end
    end
  end

  rescue_from StandardError do |exception|
    GraphQL::ExecutionError.new(exception.message)
  end
end
