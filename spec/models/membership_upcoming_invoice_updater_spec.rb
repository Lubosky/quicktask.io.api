require 'rails_helper'

RSpec.describe MembershipUpcomingInvoiceUpdater do
  before :each do
    StripeMock.start
  end

  after :each do
    StripeMock.stop
  end

  it 'updates the next_payment_amount and next_payment_on for the given subscriptions' do
    stub_stripe_plan('tms.GliderPath.AirborneBucket.Monthly')
    stub_stripe_customer_with_subscription

    workspace = create(:workspace, stripe_customer_id: 'customer123')
    membership = create(:membership, workspace: workspace)

    MembershipUpcomingInvoiceUpdater.new([membership]).process

    membership.reload

    expect(membership.next_payment_on).to eq(Date.current + 14.days)
  end

  it 'sets the next_payment_amount to 0 when it is 404' do
    error = Stripe::InvalidRequestError.new(
              'No upcoming invoices for customer',
              nil,
              http_status: 404
            )

    StripeMock.prepare_error(error, :upcoming_invoice)

    membership = create(:membership)

    MembershipUpcomingInvoiceUpdater.new([membership]).process

    membership.reload
    expect(membership.next_payment_amount).to eq(0)
    expect(membership.next_payment_on).to be_nil
  end

  it 'doesn\'t update associated workspaces with empty Stripe customer IDs' do
    workspace = create(:workspace, stripe_customer_id: '')
    membership = build_stubbed(:membership, workspace: workspace)

    MembershipUpcomingInvoiceUpdater.new([membership]).process

    membership.expects(:update!).never
  end

  it 'sends the error to Raven if it isn\'t 404' do
    error = Stripe::InvalidRequestError.new(
              'Server error',
              nil,
              http_status: 500
            )

    StripeMock.prepare_error(error, :upcoming_invoice)

    stub_stripe_plan('tms.GliderPath.AirborneBucket.Monthly')
    stub_stripe_customer_with_subscription

    workspace = create(:workspace, stripe_customer_id: 'customer123')
    membership = create(:membership, workspace: workspace)

    Raven.expects(:capture_exception).with(error)
    MembershipUpcomingInvoiceUpdater.new([membership]).process
  end

  private

  def stub_stripe_customer_with_subscription
    customer = Stripe::Customer.create(id: 'customer123')
    customer.subscriptions.create(plan: 'tms.GliderPath.AirborneBucket.Monthly', trial_end: nil)
  end
end
