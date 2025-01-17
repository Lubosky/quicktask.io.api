Types::ContractorType = GraphQL::ObjectType.define do
  name 'Contractor'
  description ''

  field :id, !types.ID, 'Globally unique ID of the contractor.'
  field :uuid, !types.String, 'A unique substitute for a contractor ID.'

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :name, types.String, 'The name of the contractor.'
  field :first_name, types.String, 'The first name of the contractor.'
  field :last_name, types.String, 'The last name of the contractor.'
  field :business_name, types.String, 'Contractor’s business name.'
  field :email, types.String, 'The email of the contractor.'
  field :phone, types.String, 'The phone of the contractor.'
  field :currency, Types::CurrencyType, 'The currency of the contractor.'
  field :rates_count, Types::BigDecimalType, ''

  connection :rates_connection, Connections::RatesConnection do
    description ''

    before_scope ->(obj, _args, _ctx) {
      AssociationLoader.for(Contractor, :contractor_rates).load(obj)
    }

    resolve ->(collection, _args, _ctx) { collection }
  end

  field :contractor_rates, types[!Types::RateType] do
    description ''

    before_scope ->(obj, _args, _ctx) {
      AssociationLoader.for(Contractor, :contractor_rates).load(obj)
    }

    resolve ->(collection, _args, _ctx) { collection }
  end

  field :member_rates, types[!Types::RateType] do
    description ''
    argument :task_id, types.ID

    before_scope ->(obj, args, _ctx) {
      if args[:task_id]
        RecordLoader.for(Task).load(args[:task_id]).then do |task|
          if task && task.assignable?
            RecordLoader.for(Rate::Contractor, column: :owner_id, where: task.query_fields).load(obj.id).then do |collection|
              Array.wrap(collection)
            end
          else
            []
          end
        end
      else
        AssociationLoader.for(Contractor, :contractor_rates).load(obj)
      end
    }

    resolve ->(collection, _args, _ctx) { collection }
  end

  field :tags, types[!Types::TagType] do
    description ''
    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(Contractor, :tags).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end

  field :created_at, Types::DateTimeType, 'The time at which this record was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this record was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this record was deleted.'
end
