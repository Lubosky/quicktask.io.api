require 'rails_helper'

RSpec.describe Todo, type: :model do
  subject { create(:todo) }

  context 'validations' do
    before do
      Todo.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:task) }
    it {
      is_expected.to belong_to(:assignee).
        class_name('WorkspaceAccount').
        with_foreign_key(:assignee_id).optional
    }
    it { is_expected.to belong_to(:workspace).without_validating_presence }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
