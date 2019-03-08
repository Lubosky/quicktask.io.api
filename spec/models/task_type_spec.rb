require 'rails_helper'

RSpec.describe TaskType, type: :model do
  subject { create(:task_type) }

  context 'validations' do
    before do
      TaskType.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to have_many(:service_tasks) }
    it { is_expected.to have_many(:services).through(:service_tasks) }

    it { is_expected.to validate_presence_of(:classification) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity.scoped_to(:workspace_id) }

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
