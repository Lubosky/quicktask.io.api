require 'rails_helper'

RSpec.describe ProjectEstimate, type: :model do
  context 'validations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:quote) }

    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:quote) }
  end
end
