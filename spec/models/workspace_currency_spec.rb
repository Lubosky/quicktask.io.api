require 'rails_helper'

RSpec.describe WorkspaceCurrency, type: :model do
  subject { create(:workspace_currency) }

  context 'validations' do
    before do
      WorkspaceCurrency.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to validate_uniqueness_of(:code).ignoring_case_sensitivity.scoped_to(:workspace_id) }

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
