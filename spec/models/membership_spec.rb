require 'rails_helper'

RSpec.describe Membership, type: :model do
  subject { build(:membership) }

  context 'validations' do
    before do
      Membership.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }
    it { is_expected.to belong_to(:plan) }
    it { is_expected.to belong_to(:owner).class_name('User').with_foreign_key(:owner_id) }

    it { is_expected.to have_many(:charges) }

    it { is_expected.to validate_presence_of(:workspace_id) }
    it { is_expected.to validate_presence_of(:plan_id) }
    it { is_expected.to validate_presence_of(:owner_id) }

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end

  context 'delegations' do
    it { should delegate_method(:stripe_customer_id).to(:workspace).as(:stripe_customer_id) }
    it { should delegate_method(:stripe_plan_id).to(:plan).as(:stripe_plan_id) }
    it { should delegate_method(:trial_period_days).to(:plan).as(:trial_period_days) }
  end

  context 'scopes' do
    describe '.next_payment_in_2_days' do
      it 'only includes membership that will be billed in 2 days' do
        billed_today = create(:membership, next_payment_on: Date.current)
        billed_tomorrow = create(:membership, next_payment_on: Date.current + 1.day)
        billed_2_days_from_now = create(:membership, next_payment_on: Date.current + 2.days)
        billed_3_days_from_now = create(:membership, next_payment_on: Date.current + 3.days)

        expect(Membership.next_payment_in_2_days).to eq [billed_2_days_from_now]
      end
    end

    describe '.restarting_today' do
      context 'membership has already been reactivated today' do
        it 'returns nothing' do
          create(:paused_membership_restarting_today, reactivated_on: Time.now)

          expect(Membership.restarting_today).to be_empty
        end
      end

      context 'no memberships are scheduled for today' do
        it 'returns nothing' do
          create(
            :inactive_membership,
            scheduled_for_reactivation_on: 4.days.ago
          )
          create(
            :inactive_membership,
            scheduled_for_reactivation_on: 4.days.from_now
          )

          expect(Membership.restarting_today).to be_empty
        end
      end

      it 'returns memberships that are cancelled but restart today' do
        create_list(:paused_membership_restarting_today, 2)

        expect(Membership.restarting_today.count).to eq 2
      end
    end

    describe '.restarting_in_two_days' do
      it 'returns nothing when no memberships are scheduled' do
        create(
          :inactive_membership,
          scheduled_for_reactivation_on: 4.days.ago
        )
        create(
          :inactive_membership,
          scheduled_for_reactivation_on: 4.days.from_now
        )

        expect(Membership.restarting_in_two_days).to be_empty
      end

      it 'returns memberships that restart in 2 days' do
        create(
          :inactive_membership,
          scheduled_for_reactivation_on: 2.days.from_now
        )

        expect(Membership.restarting_in_two_days.count).to eq 1
      end
    end

    describe '.canceled_in_last_30_days' do
      it 'returns nothing when none have been canceled within 30 days' do
        create(:membership, deactivated_on: 60.days.ago)

        expect(Membership.canceled_in_last_30_days).to be_empty
      end

      it 'returns the memberships canceled within 30 days' do
        membership = create(:membership, deactivated_on: 7.days.ago)

        expect(Membership.canceled_in_last_30_days).to eq [membership]
      end
    end

    describe '.active_as_of' do
      it 'returns nothing when no memberships canceled' do
        expect(Membership.active_as_of(Time.zone.now)).to be_empty
      end

      it 'returns nothing when membership canceled before the given date' do
        create(:membership, deactivated_on: 9.days.ago)

        expect(Membership.active_as_of(8.days.ago)).to be_empty
      end

      it 'returns the memberships canceled after the given date' do
        membership = create(:membership, deactivated_on: 7.days.ago)

        expect(Membership.active_as_of(8.days.ago)).to eq [membership]
      end

      it 'returns the memberships not canceled' do
        membership = create(:membership)

        expect(Membership.active_as_of(8.days.ago)).to eq [membership]
      end
    end

    describe '.created_before' do
      it 'returns nothing when the are no memberships' do
        expect(Membership.created_before(Time.zone.now)).to be_empty
      end

      it 'returns nothing when nothing has been created before the given date' do
        create(:membership, created_at: 1.day.ago)

        expect(Membership.created_before(2.days.ago)).to be_empty
      end

      it 'returns the memberships created before the given date' do
        membership = create(:membership, created_at: 2.days.ago)

        expect(Membership.created_before(1.day.ago)).to eq [membership]
      end
    end
  end

  describe '#active?' do
    it 'returns true if deactivated_on is nil' do
      membership = Membership.new(deactivated_on: nil)
      expect(membership).to be_active
    end

    it 'returns false if deactivated_on is not nil' do
      membership = Membership.new(deactivated_on: Time.zone.today)
      expect(membership).not_to be_active
    end
  end

  describe '#scheduled_for_deactivation?' do
    it 'returns false if scheduled_for_deactivation_on is nil' do
      membership = Membership.new(scheduled_for_deactivation_on: nil)

      expect(membership).not_to be_scheduled_for_deactivation
    end

    it 'returns true if scheduled_for_deactivation_on is not nil' do
      membership = Membership.new(
        scheduled_for_deactivation_on: Time.zone.today
      )

      expect(membership).to be_scheduled_for_deactivation
    end
  end

  describe 'owner?' do
    context 'when the given user is the owner' do
      it 'returns true' do
        user = User.new
        membership = build_stubbed(:membership, owner: user)

        expect(membership.owner?(user)).to eq true
      end
    end

    context 'when the given user is not the owner' do
      it 'returns false' do
        user = User.new
        membership = build_stubbed(:membership)

        expect(membership.owner?(user)).to eq false
      end
    end
  end

  describe '#stripe_customer_id' do
    it 'should return workspace\'s `stripe_customer_id` attribute' do
      workspace = create(:workspace, :with_membership, stripe_customer_id: 'cus_123')

      expect(workspace.membership.stripe_customer_id). to eq('cus_123')
    end
  end

  describe '#stripe_plan_id' do
    it 'delegates to plan' do
      plan = build_stubbed(:plan, stripe_plan_id: 'plan.Glider.Monthly')
      membership = build_stubbed(:membership, plan: plan)

      expect(membership.stripe_plan_id).to eq 'plan.Glider.Monthly'
    end
  end

  context '#fulfill' do
    before :each do
      StripeMock.start
      stub_stripe_plan('AirborneBucket.Monthly')
    end

    after :each do
      StripeMock.stop
    end

    it 'creates a membership' do
      membership = build(:membership)

      expect{ membership.fulfill }.to change(Membership, :count).by(1)
    end

    it 'does not fulfill with a bad credit card' do
      StripeMock.prepare_card_error(:card_declined, :new_customer)

      membership = build(:membership)

      expect{ membership.fulfill }.not_to change(Membership, :count)
    end
  end

  context '#fulfill_update' do
    before :each do
      StripeMock.start
      stub_stripe_plans
    end

    after :each do
      StripeMock.stop
    end

    it 'updates the membership\'s plan for given quantity and interval in Stripe' do
      customer = Stripe::Customer.create(id: 'original')
      customer.subscriptions.create(plan: 'tms.GliderPath.AirborneBucket.Monthly')
      plan = create(:plan)
      create(:plan, :annual_with_range_up_to_15)

      workspace = create(:workspace, stripe_customer_id: 'original')
      membership = build(:membership, workspace: workspace, plan: plan)

      membership.fulfill && membership.reload

      subscription = Stripe::Subscription.retrieve(membership.stripe_subscription_id)

      expect(subscription.customer).to eq('original')
      expect(subscription.quantity).to eq(1)
      expect(subscription.plan.interval).to eq('month')

      membership.fulfill_update(interval: 'year', quantity: 10)

      updated_subscription = Stripe::Subscription.retrieve(membership.stripe_subscription_id)

      expect(updated_subscription.customer).to eq('original')
      expect(updated_subscription.quantity).to eq(10)
      expect(updated_subscription.plan.interval).to eq('year')
    end

    it 'updates the membership\'s quantity' do
      customer = Stripe::Customer.create(id: 'original')
      customer.subscriptions.create(plan: 'tms.GliderPath.AirborneBucket.Monthly')
      plan = create(:plan)
      create(:plan, :annual_with_range_up_to_15)

      workspace = create(:workspace, stripe_customer_id: 'original')
      membership = build(:membership, workspace: workspace, plan: plan)

      membership.fulfill && membership.reload

      expect(membership.quantity).to eq(1)
      expect(membership.billing_interval).to eq('month')

      membership.fulfill_update(interval: 'year', quantity: 10)
      membership.reload

      expect(membership.quantity).to eq(10)
      expect(membership.billing_interval).to eq('year')
    end
  end

  describe '#deactivate' do
    it 'updates the membership record by setting deactivated_on to today' do
      membership = create(:active_membership)

      membership.deactivate!

      expect(membership.deactivated_on).to eq Time.zone.today
    end
  end

  context '#coupon' do
    before { StripeMock.start }
    after { StripeMock.stop }

    it 'returns a coupon from stripe_coupon' do
      stub_stripe_coupon('5OFF')
      membership = build(:membership, stripe_coupon: '5OFF')

      expect(membership.coupon.code).to eq '5OFF'
    end
  end

  context '#has_invalid_coupon?' do
    before { StripeMock.start }
    after { StripeMock.stop }

    context 'with no coupon' do
      it 'returns false' do
        membership = build(:membership, stripe_coupon: nil)

        expect(membership).not_to have_invalid_coupon
      end
    end

    context 'with a valid coupon' do
      it 'returns false' do
        stub_stripe_coupon('5OFF')

        membership = build(:membership, stripe_coupon: '5OFF')

        expect(membership).not_to have_invalid_coupon
      end
    end

    context 'with an invalid coupon' do
      it 'returns true' do
        stub_stripe_coupon('50OFF')

        membership = build(:membership, stripe_coupon: '50OFF')

        expect(membership).to have_invalid_coupon
      end
    end
  end
end
