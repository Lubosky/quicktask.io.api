require 'rails_helper'

RSpec.describe Task, type: :model do
  subject { build(:task) }

  context 'validations' do
    before do
      Task.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:source_language).class_name('Language') }
    it { is_expected.to belong_to(:target_language).class_name('Language') }
    it { is_expected.to belong_to(:task_type) }
    it { is_expected.to belong_to(:tasklist) }
    it { is_expected.to belong_to(:unit) }
    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to have_many(:todos) }

    it { is_expected.to validate_presence_of(:owner) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
