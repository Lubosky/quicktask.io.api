require 'rails_helper'

RSpec.describe TeamMember, type: :model do
  subject { build(:team_member) }

  context 'validations' do
    before do
      TeamMember.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }
  end
end
