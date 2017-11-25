require 'rails_helper'

RSpec.describe ProjectGroup, type: :model do
  subject { build(:project_group) }

  context 'validations' do
    before do
      ProjectGroup.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:client) }
    it { is_expected.to validate_presence_of(:workspace) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
