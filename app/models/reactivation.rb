class Reactivation
  def initialize(membership:)
    @membership = membership
  end

  attr_reader :membership

  def fulfill
    can_fulfill? && fulfill_reactivation
  end

  private

  def fulfill_reactivation
    membership.reactivate
  end

  def can_fulfill?
    membership.scheduled_for_deactivation?
  end
end
