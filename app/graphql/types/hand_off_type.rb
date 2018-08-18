Types::HandOffType = GraphQL::ObjectType.define do
  name 'HandOff'
  description ''

  field :id, !types.ID, 'Globally unique ID of the hand-off.'
  field :uuid, !types.String, 'A unique substitute for a hand-off ID.'

  field :assignee_type, !types.String, 'Type of the workspace user.'
  field :assignee, Types::MemberType do
    description ''

    before_scope ->(obj, _args, _ctx) {
      if obj.assignee_type == 'TeamMember'
        AssociationLoader.for(TeamMember, :assignee).load(obj)
      elsif obj.assignee_type == 'Contractor'
        AssociationLoader.for(Contractor, :assignee).load(obj)
      elsif obj.assignee_type == 'ClientContact'
        AssociationLoader.for(ClientContact, :assignee).load(obj)
      end
    }

    resolve ->(resource, _args, _ctx) { resource }
  end

  field :assigner_id, !types.ID, 'Globally unique ID of the assigner.'
  field :assigner, Types::TeamMemberType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(HandOff, :assigner).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :task_id, !types.ID, 'Globally unique ID of the task.'
  field :project_id, !types.ID, 'Globally unique ID of the project.'
  field :workspace_id, !types.ID, 'Globally unique ID of the workspace.'

  field :valid_through, Types::DateTimeType, 'The time at which this hand-off will expire.'
  field :rate_applied, !Types::BigDecimalType, ''
  field :accepted_at, Types::DateTimeType, 'The time at which this hand-off was accepted.'
  field :rejected_at, Types::DateTimeType, 'The time at which this hand-off was rejected.'
  field :expired_at, Types::DateTimeType, 'The time at which this hand-off expired.'
  field :cancelled_at, Types::DateTimeType, 'The time at which this hand-off was cancelled.'

  field :canceller_id, !types.ID, 'Globally unique ID of the canceller.'
  field :canceller, Types::TeamMemberType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(HandOff, :canceller).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end

  field :status, !types.String, ''

  field :view_count, !types.Int, ''
  field :last_viewed_at, Types::DateTimeType, 'The time at which this hand-off was last viewed.'
  field :email_count, !types.Int, ''
  field :last_emailed_at, Types::DateTimeType, 'The time at which this hand-off last emailed.'

  field :assignment, types.Boolean, ''

  field :is_assignment, types.Boolean do
    description ''
    property :assignment?
  end

  field :is_invitation, types.Boolean do
    description ''
    property :invitation?
  end

  field :purchase_order, Types::PurchaseOrderType do
    description ''

    before_scope ->(obj, _args, _ctx) { AssociationLoader.for(HandOff, :purchase_order).load(obj) }
    resolve ->(resource, _args, _ctx) { resource }
  end
end
