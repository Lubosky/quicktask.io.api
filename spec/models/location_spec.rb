require 'rails_helper'

RSpec.describe Location, type: :model do
  context 'validations' do
    it { is_expected.to belong_to(:addressable) }
    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:workspace) }
  end
end
