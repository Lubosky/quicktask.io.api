# frozen_string_literal: true

class Instrumenters::ErrorInstrumenter
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def instrument(_type, field)
    old_resolve = field.resolve_proc
    field.redefine do
      resolve = ->(obj, args, ctx) {
        begin
          old_resolve.call(obj, args, ctx)
        rescue ActiveRecord::RecordNotFound
          # NO RESULTS
          nil
        rescue ActiveRecord::RecordInvalid => err
          # GraphQL ERROR WITH VALIDATION DETAILS
          err.record.errors.each do |field_name, errors|
            errors.each do |msg|
              GraphQL::ExecutionError.new(`#{field_name}: #{msg}`)
            end
          end
          nil
        rescue StandardError => err
          GraphQL::ExecutionError.new(err.message) # ALL OTHER ERRORS
        end
      }
    end
  end
end
