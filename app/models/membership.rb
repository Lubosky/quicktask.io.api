class Membership < ApplicationRecord
  include EnsureUUID

  belongs_to :owner, inverse_of: :owned_memberships, class_name: 'User', foreign_key: :owner_id
  belongs_to :plan, inverse_of: :memberships
  belongs_to :workspace, inverse_of: :membership

  scope :active_as_of, ->(time) {
    where('deactivated_on is null OR deactivated_on > ?', time)
  }
  scope :canceled_within_period, ->(start_time, end_time) {
    where(deactivated_on: start_time...end_time)
  }
  scope :canceled_in_last_30_days, -> {
    canceled_within_period(30.days.ago, Time.zone.now)
  }
  scope :created_before, ->(time) { where('created_at <= ?', time) }
  scope :next_payment_in_2_days, -> { where(next_payment_on: 2.days.from_now) }
  scope :recent, -> { where('created_at > ?', 24.hours.ago) }
  scope :restarting_today, -> {
    where.not(deactivated_on: nil).
      where(reactivated_on: nil, scheduled_for_reactivation_on: Time.zone.today)
  }
  scope :restarting_in_two_days, -> {
    where.not(deactivated_on: nil).
      where(scheduled_for_reactivation_on: Time.zone.today + 2.days)
  }

  validates :owner_id, presence: true
  validates :plan_id, presence: true
  validates :workspace_id, presence: true, uniqueness: { conditions: -> { where(deleted_at: nil) } }

  delegate :billing_interval, :stripe_plan_id, :trial_period_days, to: :plan
  delegate :stripe_customer_id, to: :workspace

  attr_accessor :stripe_coupon, :stripe_token

  enum status: { trialing: 0, active: 1, unpaid: 2, deactivated: 3 } do
    event :activate do
      transition all - [:active, :deactivated] => :active
    end

    event :mark_as_unpaid do
      transition [:trialing, :active] => :unpaid
    end

    event :deactivate do
      before do
        self.deactivated_on = Time.zone.today
      end

      transition all - [:deactivated] => :deactivated
    end

    event :reactivate do
      before do
        self.scheduled_for_deactivation_on = nil
        reactivate_stripe_subscription
      end

      transition all => :active
    end
  end

  def active?
    deactivated_on.nil?
  end

  def scheduled_for_deactivation?
    scheduled_for_deactivation_on.present?
  end

  def fulfill
    transaction do
      create_membership
      update_next_invoice_info
    end
  end

  def fulfill_update(interval:, quantity:)
    plan = find_plan(interval: interval, quantity: quantity)

    transaction do
      update_membership(plan: plan, quantity: quantity)
      update_next_invoice_info
    end
  end

  def coupon
    @coupon ||= Coupon.new(stripe_coupon)
  end

  def has_invalid_coupon?
    stripe_coupon.present? && !coupon.valid?
  end

  def owner?(other_user)
    owner == other_user
  end

  private

  def create_membership
    if create_stripe_subscription && save
      self.tap do |membership|
        membership.status ||= :trialing
        membership.stripe_subscription_id = stripe_subscription.id
        membership.trial_period_end_date = Time.current + trial_period_days.days
        membership.save
      end
      update_stripe_customer_id
    end
  end

  def create_stripe_subscription
    stripe_subscription.create
  end

  def update_membership(plan:, quantity:)
    if update_stripe_subscription(plan: plan, quantity: quantity)
      self.tap do |membership|
        membership.plan = plan
        membership.quantity = quantity
        membership.save
      end
    end
  end

  def update_stripe_subscription(plan:, quantity:)
    subscription = stripe_customer.subscriptions.retrieve(stripe_subscription_id)
    subscription.plan = plan.stripe_plan_id
    subscription.quantity = quantity
    subscription.prorate = true

    subscription.save
  end

  def reactivate_stripe_subscription
    subscription = stripe_customer.subscriptions.retrieve(stripe_subscription_id)
    subscription.plan = subscription.plan.id
    subscription.save
  end

  def update_stripe_customer_id
    workspace.stripe_customer_id = stripe_customer_id
    workspace.activate
  end

  def update_next_invoice_info
    MembershipUpcomingInvoiceUpdater.new([self]).process
  end

  def find_plan(quantity:, interval:)
    @_plan ||= Plan.find_by(quantity: quantity, interval: interval)
  end

  def stripe_customer
    @_stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id)
  end

  def stripe_subscription
    @_stripe_subscription ||= StripeSubscription.new(self)
  end
end
