require 'rails_helper'

RSpec.describe Reactivation do
  before :each do
    StripeMock.start
    stub_stripe_plan('tms.GliderPath.AirborneBucket.Monthly')
  end

  after :each do
    StripeMock.stop
  end

  context '#fulfill' do
    it 'returns false if we cnanot fulfill in the first place' do
      reactivation = build_reactivation

      expect(reactivation.fulfill).to be false
    end

    it 'tries to reactivate on the membership if it can fulfill' do
      stub_stripe_customer_with_cancelled_subscription

      canceled_subscription = Stripe::Subscription.retrieve(@membership.stripe_subscription_id)

      expect(canceled_subscription.cancel_at_period_end).to be_truthy
      expect(@membership.scheduled_for_deactivation_on).not_to be_nil

      reactivation = Reactivation.new(membership: @membership)
      reactivation.fulfill

      reactivated_subscription = Stripe::Subscription.retrieve(@membership.stripe_subscription_id)

      expect(reactivated_subscription.cancel_at_period_end).to be_falsey
      expect(@membership.scheduled_for_deactivation_on).to be_nil
    end
  end

  def build_reactivation(membership: create(:membership, workspace: workspace))
    Reactivation.new(membership: membership)
  end

  def workspace
    @workspace ||= create(:workspace, stripe_customer_id: 'customer123')
  end

  def stub_stripe_customer_with_cancelled_subscription
    customer = Stripe::Customer.create(id: 'customer123')

    @membership = build(:membership, workspace: workspace)
    stripe_subscription = @membership.fulfill

    cancellation = Cancellation.new(membership: @membership)
    cancellation.schedule
  end
end
