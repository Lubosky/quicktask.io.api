require 'rails_helper'

RSpec.describe Plan, type: :model do
  subject { create(:plan) }

  context 'validations' do
    before do
      Plan.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to have_many(:memberships) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:stripe_plan_id) }
    it { is_expected.to validate_uniqueness_of(:stripe_plan_id) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end

  describe '.find_by' do
    it 'returns the plan where the quantity is in range and interval matches' do
      plan_option = create(:plan, :with_range_up_to_15)
      create(:plan, :with_range_up_to_15, :annual)
      create(:plan, :with_range_up_to_100)

      plan = Plan.find_by(quantity: 7, interval: :month)

      expect(plan.allowance).to eq plan_option.range.max
      expect(plan.name).to eq plan_option.name
      expect(plan.price).to eq plan_option.price
      expect(plan.billing_interval).to eq plan_option.billing_interval
    end
  end

  describe '#allowance' do
    it 'returns the upper bound of the range' do
      plan1 = build(:plan)
      plan2 = build(:plan, :with_range_up_to_15)
      plan3 = build(:plan, :with_range_up_to_100)

      expect(plan1.allowance).to eq 5
      expect(plan2.allowance).to eq 15
      expect(plan3.allowance).to eq 100
    end
  end

  describe '#free_license?' do
    it 'returns true' do
      plan = build(:plan, price: 0)

      expect(plan).to be_free_license
    end

    context 'when the price is positive' do
      it 'returns false' do
        plan = build(:plan)

        expect(plan).to_not be_free_license
      end
    end
  end
end
