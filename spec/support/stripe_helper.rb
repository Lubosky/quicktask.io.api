module StripeHelper
  def stripe_helper
    StripeMock.create_test_helper
  end

  def stripe_coupons
    YAML.load_file(Rails.root.join('spec', 'fixtures', 'stripe_coupons.yml'))
  end

  def stripe_plans
    YAML.load_file(Rails.root.join('spec', 'fixtures', 'stripe_plans.yml'))
  end

  def stub_stripe_coupon(name)
    coupon = stripe_coupons.detect { |stripe_coupon| stripe_coupon['id'].match?(name) }

    Stripe::Coupon.create(coupon)
  end

  def stub_stripe_coupons
    stripe_coupons.each { |coupon| Stripe::Coupon.create(coupon) }
  end

  def stub_stripe_plan(name)
    plan = stripe_plans.detect { |stripe_plan| stripe_plan['id'].match?(name) }

    stripe_helper.create_plan(plan)
  rescue Stripe::InvalidRequestError
    nil
  end

  def stub_stripe_plans
    stripe_plans.each { |plan| stripe_helper.create_plan(plan) }
  rescue Stripe::InvalidRequestError
    nil
  end
end
