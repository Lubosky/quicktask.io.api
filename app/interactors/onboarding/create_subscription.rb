class Onboarding::CreateSubscription < ApplicationInteractor
  string :interval
  integer :quantity

  string :stripe_coupon, default: nil
  string :stripe_token

  def execute
    transaction do
      unless membership.fulfill && membership.errors.none?
        errors.merge!(membership.errors)
        rollback
      end
    end
    membership
  end

  private

  def membership
    @membership ||= Membership.
      where(workspace: workspace).
      first_or_initialize(membership_attributes)
  end

  def plan
    @plan ||= Plan.find_by(quantity: quantity, interval: interval)
  end

  def user
    @user ||= current_user
  end

  def workspace
    @workspace ||= current_workspace
  end

  def membership_attributes
    attributes.slice(:stripe_coupon, :stripe_token, :quantity).tap do |hash|
      hash[:owner] = user
      hash[:plan] = plan
    end
  end
end
