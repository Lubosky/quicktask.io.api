RSpec::Matchers.define :have_active_membership do |plan|
  match do |workspace|
    workspace.membership.present? && workspace.membership.plan.stripe_plan_id == plan.stripe_plan_id
  end
end
