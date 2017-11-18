require 'rails_helper'

RSpec.describe Rolify::Base, type: :model do
  subject { build(:owner_role) }

  context 'validations' do
    before do
      Rolify::Base.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }
    it { is_expected.to have_many(:members).through(:workspace).class_name('WorkspaceUser') }

    it { is_expected.to validate_presence_of(:permission_level) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:workspace_id) }
    it { is_expected.to validate_length_of(:name).is_at_most(45) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
