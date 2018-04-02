require 'rails_helper'

RSpec.describe Proposal, type: :model do
  context 'validations' do
    it { is_expected.to belong_to(:client_request) }
    it { is_expected.to belong_to(:quote) }

    it { is_expected.to validate_presence_of(:client_request) }
    it { is_expected.to validate_presence_of(:quote) }
  end
end
