require 'rails_helper'

RSpec.describe Project::Template, type: :model do
  subject { create(:project_template) }

  context 'validations' do
    before do
      Project::Template.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:client).optional }
    it { is_expected.to belong_to(:owner).class_name('TeamMember').with_foreign_key(:owner_id).optional }
    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to have_many(:tasklists) }
    it { is_expected.to have_many(:tasks) }

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
