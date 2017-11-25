require 'rails_helper'

RSpec.describe WorkspaceUser, type: :model do
  subject { build(:workspace_user) }

  context 'validations' do
    before do
      WorkspaceUser.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:member) }
    it { is_expected.to belong_to(:role).class_name('Role::Base') }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:workspace) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to([:member_type, :member_id]) }

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end

  context 'delegations' do
    it { should delegate_method(:first_name).to(:user).as(:first_name) }
    it { should delegate_method(:last_name).to(:user).as(:last_name) }
    it { should delegate_method(:locale).to(:user).as(:locale) }
    it { should delegate_method(:time_zone).to(:user).as(:time_zone) }
    it { should delegate_method(:settings).to(:user).as(:settings) }
    it { should delegate_method(:permission_level).to(:role).as(:permission_level) }
  end
end
