require 'rails_helper'

RSpec.describe Charge, type: :model do
  let!(:workspace) { create(:workspace) }
  subject { build(:charge, workspace: workspace) }

  context 'validations' do
    before do
      Charge.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }
    it { is_expected.to have_one(:membership) }

    it { is_expected.to validate_presence_of(:stripe_invoice_id) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_presence_of(:workspace_id) }
    it { is_expected.to validate_uniqueness_of(:stripe_invoice_id) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
