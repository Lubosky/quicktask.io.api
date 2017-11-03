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

  delegate :stripe_customer_id, to: :workspace
  delegate :stripe_plan_id, :trial_period_days, to: :plan

  alias_attribute :quantity, :team_member_limit

  attr_accessor :quantity, :stripe_coupon, :stripe_token

  enum status: { trialing: 0, active: 1, past_due: 2, unpaid: 3, deactivated: 4 } do
    event :activate do
      transition all - [:active] => :active
    end

    event :deactivate do
      transition all - [:deactivated] => :deactivated
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

  def update_stripe_customer_id
    workspace.update(stripe_customer_id: stripe_customer_id)
  end

  def stripe_subscription
    @stripe_subscription ||= StripeSubscription.new(self)
  end
end
