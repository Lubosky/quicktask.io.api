require 'rails_helper'

RSpec.describe TeamMember, type: :model do
  subject { build(:team_member) }

  context 'validations' do
    before do
      TeamMember.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to have_many(:assignments).class_name('HandOff').with_foreign_key(:assignee_id) }
    it { is_expected.to have_many(:delegated_hand_offs).class_name('HandOff').with_foreign_key(:assigner_id) }
    it { is_expected.to have_many(:projects).class_name('Project::Base').with_foreign_key(:owner_id) }
    it { is_expected.to have_many(:tasklists).class_name('Tasklist').with_foreign_key(:owner_id) }
    it { is_expected.to have_many(:tasks).class_name('Task').with_foreign_key(:owner_id) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity.scoped_to(:workspace_id) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
