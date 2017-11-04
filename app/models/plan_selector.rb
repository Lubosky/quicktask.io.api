class PlanSelector
  def initialize(membership)
    @membership = membership
  end

  def current_plan
    find_plan(member_count)
  end

  def next_plan
    find_plan(member_count.succ)
  end

  def previous_plan
    find_plan(member_count.pred)
  end

  def upgrade?
    current_plan != next_plan
  end

  private

  attr_reader :membership

  def billing_interval
    membership.billing_interval
  end

  def member_count
    @_member_count ||= workspace.team_member_count
  end

  def workspace
    @_workspace ||= membership.workspace
  end

  def find_plan(count)
    Plan.find_by(count: count, interval: billing_interval)
  end
end
