require 'rails_helper'

RSpec.describe Client, type: :model do
  subject { build(:client) }

  context 'validations' do
    before do
      Client.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to have_many(:client_contacts) }

    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_length_of(:currency).is_equal_to(3) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end
end
