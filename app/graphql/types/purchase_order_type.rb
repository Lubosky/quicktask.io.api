Types::PurchaseOrderType = GraphQL::ObjectType.define do
  name 'PurchaseOrder'
  description ''

  field :id, !types.ID, 'Globally unique ID of the purchase order.'
  field :uuid, !types.String, 'A unique substitute for a purchase order ID.'

  field :owner_type, !types.String, 'Type of the workspace user.'
  field :owner_id, !types.ID, 'Globally unique ID of the owner.'
  field :owner, Types::ProfileType do
    description ''

    before_scope ->(obj, _args, _ctx) {
      if obj.owner_type == 'TeamMember'
        AssociationLoader.for(PurchaseOrder, :owner).load(obj)
      elsif obj.owner_type == 'Contractor'
        AssociationLoader.for(PurchaseOrder, :owner).load(obj)
      elsif obj.owner_type == 'ClientContact'
        AssociationLoader.for(PurchaseOrder, :owner).load(obj)
      end
    }

    resolve ->(resource, _args, _ctx) { resource }
  end

  field :issuer_id, !types.ID, 'Globally unique ID of the issuer.'
  field :issuer, Types::TeamMemberType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(PurchaseOrder, :issuer).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :updater_id, types.ID, 'Globally unique ID of the updater.'
  field :updater, Types::TeamMemberType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(PurchaseOrder, :updater).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :hand_off_id, !types.ID, 'Globally unique ID of the hand-off.'
  field :hand_off, Types::HandOffType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(PurchaseOrder, :hand_off).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'
  field :workspace, Types::WorkspaceType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(PurchaseOrder, :workspace).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :subject, types.String, ''
  field :identifier, types.String, ''
  field :purchase_order_number, types.String, ''
  field :issue_date, Types::DateTimeType, 'The time at which this purchase order was issued.'
  field :billed, !types.Boolean, ''
  field :currency, Types::CurrencyType, 'The currency of the purchase order.'
  field :currency_data, Types::JSONType, ''
  field :discount, !Types::BigDecimalType, ''
  field :surcharge, !Types::BigDecimalType, ''
  field :subtotal, !Types::BigDecimalType, ''
  field :total, !Types::BigDecimalType, ''
  field :notes, types.String, ''
  field :terms, types.String, ''

  field :created_at, Types::DateTimeType, 'The time at which this task was created.'
  field :updated_at, Types::DateTimeType, 'The time at which this task was last modified.'
  field :deleted_at, Types::DateTimeType, 'The time at which this task was deleted.'

  field :line_items do
    type types[!Types::LineItemType]
    description ''

    before_scope ->(obj, _args, ctx) { AssociationLoader.for(PurchaseOrder, :line_items).load(obj) }
    resolve ->(collection, _args, _ctx) { collection }
  end
end
