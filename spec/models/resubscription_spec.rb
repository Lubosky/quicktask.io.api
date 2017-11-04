require 'rails_helper'

RSpec.describe Resubscription do
  let(:plan) { Plan.first || create(:plan) }

  before :each do
    StripeMock.start
    stub_stripe_plan('tms.GliderPath.AirborneBucket.Monthly')
  end

  after :each do
    StripeMock.stop
  end

  context '#fulfill' do
    it 'returns false if the workspace has no credit card' do
      workspace = create(:workspace)
      workspace.expects(:has_credit_card?).returns(false)
      resubscription = Resubscription.new(workspace: workspace, plan: plan, quantity: 1)

      expect(resubscription.fulfill).to be_falsey
    end

    it 'returns false if the workspace has a subscription' do
      workspace = create(:workspace, :with_membership)
      resubscription = Resubscription.new(plan: plan, quantity: 5, workspace: workspace)

      expect(resubscription.fulfill).to be_falsey
    end

    it 'tries to reactivate on the subscription if it can fulfill' do
      workspace = create(:workspace, :with_inactive_membership, stripe_customer_id: 'customer123')
      stub_stripe_customer
      resubscription = Resubscription.new(plan: plan, quantity: 5, workspace: workspace)

      expect(stripe_customer.subscriptions.total_count).to eq(0)

      resubscription.fulfill

      expect(workspace).to have_active_membership(plan)
      expect(stripe_customer).to have_active_stripe_subscription(plan)
      expect(stripe_customer.subscriptions.total_count).to eq(1)
    end
  end

  def stripe_customer
    Stripe::Customer.retrieve('customer123')
  end

  def stub_stripe_customer
    card_token = StripeMock.generate_card_token

    Stripe::Customer.create(id: 'customer123', source: card_token)
  end
end
