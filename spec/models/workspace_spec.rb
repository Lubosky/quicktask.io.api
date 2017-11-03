require 'rails_helper'

RSpec.describe Workspace, type: :model do
  context 'validations' do
    before do
      Workspace.any_instance.stubs(:ensure_uuid).returns(true)
    end

    subject { create(:workspace) }

    it { is_expected.to belong_to(:owner).class_name('User').with_foreign_key(:owner_id) }

    it { is_expected.to have_one(:membership) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:owner_id) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to validate_length_of(:slug).is_at_least(2) }
    it { is_expected.to validate_length_of(:slug).is_at_most(18) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
