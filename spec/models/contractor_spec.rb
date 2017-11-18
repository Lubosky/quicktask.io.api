require 'rails_helper'

RSpec.describe Contractor, type: :model do
  subject { build(:contractor) }

  context 'validations' do
    before do
      Contractor.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }
  end
end
