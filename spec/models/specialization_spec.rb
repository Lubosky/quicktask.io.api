require 'rails_helper'

RSpec.describe Specialization, type: :model do
  subject { create(:specialization) }

  context 'validations' do
    before do
      Specialization.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity.scoped_to(:workspace_id) }

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
