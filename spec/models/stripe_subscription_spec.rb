require 'rails_helper'

RSpec.describe StripeSubscription do
  before :each do
    StripeMock.start
    stub_stripe_plans
  end

  after :each do
    StripeMock.stop
  end

  context '#create' do
    context 'when there is an existing Stripe customer record' do
      it 'updates the user\'s credit card' do
        Stripe::Customer.create(id: 'customer123')
        workspace = create(:workspace, stripe_customer_id: 'customer123')
        membership = build(:membership, workspace: workspace, stripe_token: 'token123')

        subscription = StripeSubscription.new(membership)
        subscription.create

        customer = Stripe::Customer.retrieve('customer123')

        expect(customer.card).to eq('token123')
      end

      it 'updates the customer\'s plan' do
        Stripe::Customer.create(id: 'customer123')
        workspace = create(:workspace, stripe_customer_id: 'customer123')
        membership = build(:membership, workspace: workspace)
        subscription = StripeSubscription.new(membership)

        subscription.create

        customer = Stripe::Customer.retrieve('customer123')

        new_subscription = customer.subscriptions.first
        expect(new_subscription.plan.id).to eq membership.stripe_plan_id
        expect(new_subscription.quantity).to eq 1
      end

      it 'updates the customer\'s plan with the given quantity' do
        Stripe::Customer.create(id: 'customer123')
        workspace = create(:workspace, stripe_customer_id: 'customer123')
        membership = build(:membership, workspace: workspace, quantity: 5)
        subscription = StripeSubscription.new(membership)

        subscription.create

        customer = Stripe::Customer.retrieve('customer123')

        new_subscription = customer.subscriptions.first
        expect(new_subscription.plan.id).to eq membership.stripe_plan_id
        expect(new_subscription.quantity).to eq(5)
      end

      it 'updates the subscription with the given coupon' do
        Stripe::Customer.create(id: 'customer123')
        stub_stripe_coupon('5OFF')
        workspace = create(:workspace, stripe_customer_id: 'customer123')
        membership = build(:membership, workspace: workspace, stripe_coupon: '5OFF')
        subscription = StripeSubscription.new(membership)

        subscription.create

        customer = Stripe::Customer.retrieve('customer123')

        new_subscription = customer.subscriptions.first
        expect(new_subscription.plan.id).to eq membership.stripe_plan_id
        expect(new_subscription.discount.coupon.id).to eq '5OFF'
        expect(new_subscription.quantity).to eq(1)
      end
    end

    it 'creates a customer if one isn\'t assigned' do
      owner = create(:user)
      workspace = create(:workspace, owner: owner)
      membership = build(:membership, workspace: workspace, owner: owner)
      subscription = StripeSubscription.new(membership)

      expect(Stripe::Customer.list.count).to eq(0)

      subscription.create

      expect(Stripe::Customer.list.count).to eq(1)
      expect(Stripe::Customer.list.first.email).to eq(membership.owner.email)
    end

    it 'doesn\'t create a customer if one is already assigned' do
      Stripe::Customer.create(id: 'original')
      workspace = create(:workspace, stripe_customer_id: 'original')
      membership = build(:membership, workspace: workspace)
      subscription = StripeSubscription.new(membership)

      subscription.create

      customer = Stripe::Customer.retrieve('original')

      expect(workspace.stripe_customer_id).to eq('original')
      expect(customer.id).to eq('original')
      expect(customer.subscriptions.count).to eq(1)
    end

    it 'it adds an error message with a bad card' do
      StripeMock.prepare_card_error(:card_declined, :new_customer)
      membership = build(:membership)
      subscription = StripeSubscription.new(membership)

      result = subscription.create

      expect(result).to be false
    end
  end
end
