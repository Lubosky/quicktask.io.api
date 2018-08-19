class HandOff < ApplicationRecord
  class HandOffCancelled < StandardError; end
  class HandOffExpired < StandardError; end

  include BelongsDirectly, EnsureUUID

  belongs_to :assignee, polymorphic: true

  with_options class_name: 'TeamMember' do
    belongs_to :assigner, foreign_key: :assigner_id
    belongs_to :canceller, foreign_key: :canceller_id, optional: true
  end

  with_options inverse_of: :hand_offs do
    belongs_to :task
    belongs_to :workspace
  end

  has_one :project, inverse_of: :hand_offs, through: :task
  has_one :purchase_order, inverse_of: :hand_off

  belongs_directly_to :workspace

  scope :accepted, -> { where.not(accepted_at: nil, assignee_id: nil) }
  scope :rejected, -> { where.not(rejected_at: nil) }
  scope :cancelled, -> { where.not(cancelled_at: nil) }
  scope :expired, -> { where.not(expired_at: nil).or(where.not(valid)) }
  scope :pristine, -> {
    table = HandOff.arel_table
    where(
      table[:accepted_at].eq(nil).
      and(table[:rejected_at].eq(nil)).
      and(table[:cancelled_at].eq(nil)).
      and(table[:expired_at].eq(nil))
    )
  }

  scope :pending, -> { pristine.valid }
  scope :valid, -> {
    table = HandOff.arel_table
    where(
      table[:valid_through].eq(nil).or(table[:valid_through].gteq(Time.current))
    )
  }

  scope :with_task, ->(task) { where(task: task) }

  validates :assignee, :assigner, :task, :workspace, presence: true
  validate :assignee_not_invited, on: :create
  validate :contractor_with_rate, on: :create

  delegate :workspace, to: :task
  delegate :hand_off_valid_period, to: :workspace

  before_create :set_valid_through
  after_create :generate_purchase_order

  def assign!
    return unless assign_directly?
    accept!
  end

  def accept!
    return unless pending?
    update!(accepted_at: Time.current, rejected_at: nil, cancelled_at: nil, expired_at: nil)
    HandOff.with_task(self.task).pristine.find_each(&:expire!)
    return self
  end

  def reject!
    return unless accepted?
    update!(accepted_at: nil, rejected_at: Time.current, cancelled_at: nil, expired_at: nil)
  end

  def cancel!(args = {})
    update!(
      args.
        slice(:canceller).
        merge(accepted_at: nil, rejected_at: nil, cancelled_at: Time.current, expired_at: nil)
    )
  end

  def expire!
    update!(accepted_at: nil, rejected_at: nil, cancelled_at: nil, expired_at: Time.current)
  end

  def status
    return :accepted if self.accepted?
    return :rejected if self.rejected?
    return :cancelled if self.cancelled?
    return :expired if self.expired?
    return :pending
  end

  def accepted?
    accepted_at.present?
  end

  def rejected?
    rejected_at.present?
  end

  def cancelled?
    cancelled_at.present?
  end

  def expired?
    expired_at.present? || passed?
  end

  def passed?
    valid_through.present? && valid_through.past?
  end

  def pending?
    !accepted? && !cancelled? && !rejected? && !expired?
  end

  def assign_directly?
    assignment?
  end

  def invitation?
    !assignment?
  end

  private

  def set_valid_through
    expiry_date = nil
    unless self.hand_off_valid_period.blank?
      expiry_date = Time.current + self.hand_off_valid_period.to_i.hours
    end

    self.valid_through ||= expiry_date
  end

  def assignee_not_invited
    return true if assignee.is_a?(TeamMember)

    if ::HandOff.with_task(self.task).pending.exists?(assignee_id: self.assignee_id, assignee_type: self.assignee_type)
      errors.add(:assignee, :already_invited)
    end
  end

  def contractor_with_rate
    return true if assignee.is_a?(TeamMember)

    unless PotentialAssigneesQuery.build_query(self.task).exists?(id: self.assignee_id)
      errors.add(:assignee, :must_have_valid_rate)
    end
  end

  def generate_purchase_order
    ::Bookkeepable::PurchaseOrder::Generator.generate(self)
  end
end
