require 'rails_helper'

RSpec.describe Language, type: :model do
  subject { build(:language) }

  context 'validations' do
    before do
      Language.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to validate_uniqueness_of(:code).ignoring_case_sensitivity.scoped_to(:workspace_id) }
    it { is_expected.to validate_inclusion_of(:code).in_array(Language::LANGUAGE_CODES) }

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
