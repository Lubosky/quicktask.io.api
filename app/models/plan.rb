class Plan < ApplicationRecord
  include EnsureUUID

  MONTHLY_PLAN_OPTIONS = %w(
    tms.GliderPath.AirborneBucket.Monthly
    tms.GliderPath.SoaringBucket.Monthly
    tms.GliderPath.CruisingBucket.Monthly
  ).freeze

  ANNUAL_PLAN_OPTIONS = %w(
    tms.GliderPath.AirborneBucket.Annually
    tms.GliderPath.SoaringBucket.Annually
    tms.GliderPath.CruisingBucket.Annually
  ).freeze

  PLAN_OPTIONS = MONTHLY_PLAN_OPTIONS + ANNUAL_PLAN_OPTIONS

  enum billing_interval: { month: 0, year: 1 }

  has_many :memberships, inverse_of: :plan

  validates_presence_of :name
  validates :stripe_plan_id, presence: true, uniqueness: true, inclusion: PLAN_OPTIONS

  def self.find_by(quantity:, interval:)
    where(billing_interval: interval).
      detect { |plan| plan&.range.include?(quantity) }
  end

  def allowance
    range.max
  end

  def free_license?
    price.zero?
  end

  private

  def stripe_plan
    @stripe_plan ||= Stripe::Plan.retrieve(stripe_plan_id)
  end
end
