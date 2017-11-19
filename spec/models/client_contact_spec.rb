require 'rails_helper'

RSpec.describe ClientContact, type: :model do
  subject { build(:client_contact) }

  context 'validations' do
    before do
      ClientContact.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:workspace) }
  end
end
