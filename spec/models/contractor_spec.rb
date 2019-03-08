require 'rails_helper'

RSpec.describe Contractor, type: :model do
  subject { create(:contractor) }

  context 'validations' do
    before do
      Contractor.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to have_many(:assignments).class_name('HandOff').with_foreign_key(:assignee_id) }
    it { is_expected.to have_many(:invitations).class_name('HandOff').with_foreign_key(:assignee_id) }
    it { is_expected.to have_many(:tasks).through(:assignments) }
    it { is_expected.to have_many(:contractor_rates).class_name('Rate::Contractor').with_foreign_key(:owner_id) }

    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_length_of(:currency).is_equal_to(3) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
