require 'rails_helper'

RSpec.describe PausedMembership do
  before :each do
    StripeMock.start
    stub_stripe_plan('tms.GliderPath.AirborneBucket.Monthly')
  end

  after :each do
    StripeMock.stop
  end

  describe '#schedule' do
    it 'sets the reactivation date to 90 days after end of billing period' do
      stub_stripe_customer_with_subscription
      membership = create_membership
      pause = PausedMembership.new(membership: membership)

      pause.schedule

      expect(membership.scheduled_for_reactivation_on).
        to eq Time.zone.at(Time.current + trial_period_days + 90.days).to_date
    end

    it 'cancels the membership' do
      stub_stripe_customer_with_subscription
      membership = create_membership
      pause = PausedMembership.new(membership: membership)

      cancellation = mock(schedule: true)
      Cancellation.expects(:new).with(membership: membership).returns(cancellation)

      expect(pause.schedule).to eq true
    end

    def workspace
      @workspace ||= create(:workspace, stripe_customer_id: 'customer123')
    end

    def create_membership
      @membership ||= create(:membership, workspace: workspace)
    end

    def stub_stripe_customer_with_subscription
      customer = Stripe::Customer.create(id: 'customer123')
      customer.subscriptions.create(plan: 'tms.GliderPath.AirborneBucket.Monthly')
    end

    def trial_period_days
      14.days
    end
  end
end
