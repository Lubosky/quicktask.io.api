require 'rails_helper'

RSpec.describe Task, type: :model do
  let!(:workspace) { create(:workspace) }
  let!(:project) { create(:project, workspace: workspace) }
  let!(:tasklist) { create(:tasklist, project: project, workspace: workspace) }
  subject { create(:task, tasklist: tasklist) }

  context 'validations' do
    before do
      Task.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:owner).class_name('TeamMember').with_foreign_key(:owner_id) }
    it { is_expected.to belong_to(:project).without_validating_presence }
    it { is_expected.to belong_to(:source_language).class_name('Language').optional }
    it { is_expected.to belong_to(:target_language).class_name('Language').optional }
    it { is_expected.to belong_to(:task_type) }
    it { is_expected.to belong_to(:tasklist) }
    it { is_expected.to belong_to(:unit).optional }

    it { is_expected.to have_many(:invitees).class_name('Contractor').with_foreign_key(:assignee_id) }
    it { is_expected.to have_many(:hand_offs) }
    it { is_expected.to have_many(:pending_hand_offs).class_name('HandOff') }
    it { is_expected.to have_many(:potential_assignees) }
    it { is_expected.to have_many(:todos) }
    it { is_expected.to have_many(:potential_assignees) }

    it { is_expected.to have_one(:team_member_assignee).with_foreign_key(:assignee_id) }
    it { is_expected.to have_one(:contractor_assignee).with_foreign_key(:assignee_id) }

    it { is_expected.to validate_presence_of(:owner) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
