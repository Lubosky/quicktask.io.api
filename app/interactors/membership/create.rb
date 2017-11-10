class Membership::Create < ApplicationInteractor
  string :interval
  integer :quantity

  string :stripe_coupon, default: nil
  string :stripe_token

  def execute
    transaction do
      unless membership.fulfill
        errors.merge!(membership.errors)
        rollback
      end
    end
    membership
  end

  private

  def membership
    @_membership ||= Membership.new(membership_attributes)
  end

  def plan
    @_plan ||= Plan.find_by(quantity: quantity, interval: interval)
  end

  def membership_attributes
    attributes.slice(:stripe_coupon, :stripe_token, :quantity).tap do |attribute|
      attribute[:owner] = current_user
      attribute[:plan] = plan
      attribute[:workspace] = current_workspace
    end
  end
end
