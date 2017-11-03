require 'rails_helper'

RSpec.describe Cancellation do
  before :each do
    StripeMock.start
    stub_stripe_plans
  end

  after :each do
    StripeMock.stop
  end

  it 'should be ActiveModel-compliant' do
    cancellation = build_cancellation

    expect(cancellation).to be_a(ActiveModel::Model)
  end

  describe '#process' do
    context 'with an active membership' do
      it 'makes the membership inactive and records the current date' do
        cancellation.process

        expect(membership.deactivated_on).to eq(Time.zone.today)
      end
    end
  end

  describe '#cancel_now' do
    it 'makes the membership inactive and records the current date' do
      stub_stripe_customer_with_subscription

      cancellation.cancel_now

      expect(membership.deactivated_on).to eq(Time.zone.today)
    end

    it 'cancels with Stripe' do
      stub_stripe_customer_with_subscription

      expect(stripe_customer.subscriptions.total_count).to eq(1)

      cancellation.cancel_now

      expect(stripe_customer.subscriptions.total_count).to eq(0)
    end

    it 'does not make the membership inactive if stripe unsubscribe fails' do
      cancellation = build_cancellation(membership: membership)
      StripeMock.prepare_error(Stripe::StripeError, :cancel_subscription)

      expect { cancellation.cancel_now }.to raise_error(Stripe::StripeError)
      expect(membership.reload).to be_active
    end
  end

  describe '#schedule' do
    it 'schedules a cancellation with Stripe' do
      Timecop.freeze(Time.current) do
        stub_stripe_customer_with_subscription
        cancellation = build_cancellation(membership: membership)

        cancellation.schedule

        membership.reload
        expect(stripe_customer.subscriptions.first.cancel_at_period_end).
          to eq(true)
        expect(membership.scheduled_for_deactivation_on).
          not_to be_nil
      end
    end

    it 'returns true' do
      stub_stripe_customer_with_subscription

      cancellation = build_cancellation

      expect(cancellation.schedule).to eq true
    end

    it 'does not make the membership inactive if stripe unsubscribe fails' do
      cancellation = build_cancellation(membership: membership)
      StripeMock.prepare_error(Stripe::StripeError, :cancel_subscription)

      expect { cancellation.schedule }.to raise_error(Stripe::StripeError)
      expect(membership.reload).to be_active
    end
  end

  def build_cancellation(membership: create(:membership, workspace: workspace))
    Cancellation.new(membership: membership)
  end

  def workspace
    @workspace ||= create(:workspace, stripe_customer_id: 'customer123')
  end

  def membership
    @membership ||= create(:membership, workspace: workspace)
  end

  def cancellation
    @cancellation ||= build_cancellation(membership: membership)
  end

  def stripe_customer
    Stripe::Customer.retrieve('customer123')
  end

  def stub_stripe_customer_with_subscription
    customer = Stripe::Customer.create(id: 'customer123')
    customer.subscriptions.create(plan: 'tms.GliderPath.AirborneBucket.Monthly')
  end
end
