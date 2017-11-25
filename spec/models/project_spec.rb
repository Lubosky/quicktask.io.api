require 'rails_helper'

RSpec.describe Project, type: :model do
  subject { build(:project) }

  context 'validations' do
    before do
      Project.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:owner).class_name('WorkspaceUser').with_foreign_key(:owner_id) }
    it { is_expected.to belong_to(:workspace) }
    it { is_expected.to belong_to(:project_group) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
