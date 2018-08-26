require 'rails_helper'

RSpec.describe Project::Base, type: :model do
  subject { build(:project) }

  context 'validations' do
    before do
      Project.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:owner).class_name('TeamMember').with_foreign_key(:owner_id) }
    it { is_expected.to belong_to(:workspace) }
    it { is_expected.to belong_to(:project_group) }

    it { is_expected.to have_many(:possible_collaborators) }
    it { is_expected.to have_many(:tasklists) }
    it { is_expected.to have_many(:tasks) }

    it { is_expected.to have_one(:project_estimate).with_foreign_key(:project_id) }
    it { is_expected.to have_one(:quote).through(:project_estimate) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end