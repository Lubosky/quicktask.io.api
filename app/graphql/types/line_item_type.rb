Types::LineItemType = GraphQL::ObjectType.define do
  name 'LineItem'
  description ''

  field :id, !types.ID, 'Globally unique ID of the line item.'
  field :uuid, !types.String, 'A unique substitute for a line item ID.'

  field :bookkeepable_type, !types.String, 'Type of the bookkeepable record.'
  field :bookkeepable, Types::BookkeepableType do
    description ''

    before_scope ->(obj, _args, _ctx) {
      if obj.bookkeepable_type == 'PurchaseOrder'
        AssociationLoader.for(LineItem, :bookkeepable).load(obj)
      end
    }

    resolve ->(resource, _args, _ctx) { resource }
  end

  field :source_language_id, types.ID, 'Globally unique ID of the language.'
  field :source_language, Types::LanguageType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(LineItem, :source_language).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :target_language_id, types.ID, 'Globally unique ID of the language.'
  field :target_language, Types::LanguageType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(LineItem, :target_language).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :task_type_id, types.ID, 'Globally unique ID of the task type.'
  field :task_type, Types::TaskTypeType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(LineItem, :task_type).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :unit_id, types.ID, 'Globally unique ID of the unit.'
  field :unit, Types::UnitType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(LineItem, :unit).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :description, types.String, ''
  field :quantity, types.Float, 'Count of the line item.'
  field :unit_price, !Types::BigDecimalType, ''
  field :discount, !Types::BigDecimalType, ''
  field :surcharge, !Types::BigDecimalType, ''
  field :subtotal, !Types::BigDecimalType, ''
  field :total, !Types::BigDecimalType, ''

  field :position, !types.Int, ''

  field :created_at, Types::DateTimeType, 'The time at which this task was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this task was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this task was deleted.'
end
