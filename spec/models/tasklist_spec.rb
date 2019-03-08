require 'rails_helper'

RSpec.describe Tasklist, type: :model do
  subject { create(:tasklist) }

  context 'validations' do
    before do
      Tasklist.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:owner).
        class_name('TeamMember').
        with_foreign_key(:owner_id).without_validating_presence
    }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:workspace).without_validating_presence }

    it { is_expected.to have_many(:tasks) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
