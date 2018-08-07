require 'rails_helper'

RSpec.describe Language, type: :model do
  subject { build(:language) }

  context 'validations' do
    before do
      Language.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to validate_uniqueness_of(:code).ignoring_case_sensitivity.scoped_to(:workspace_id) }

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }

    it 'does not raise an error if language is supported' do
      expect { create(:language, code: 'en') }.not_to raise_error
    end

    it 'raises an error if language is not supported' do
      expect { create(:language, code: 'xxx') }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
