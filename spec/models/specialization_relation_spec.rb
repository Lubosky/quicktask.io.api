require 'rails_helper'

RSpec.describe SpecializationRelation, type: :model do
  context 'validations' do
    it { is_expected.to belong_to(:specializable) }
    it { is_expected.to belong_to(:specialization) }
    it { is_expected.to have_one(:workspace).through(:specialization) }

    it { is_expected.to validate_presence_of(:specializable) }
    it { is_expected.to validate_presence_of(:specialization) }
  end
end
