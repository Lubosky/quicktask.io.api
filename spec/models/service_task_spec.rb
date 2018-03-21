require 'rails_helper'

RSpec.describe ServiceTask, type: :model do
  context 'validations' do
    it { is_expected.to belong_to(:service) }
    it { is_expected.to belong_to(:task_type) }
    it { is_expected.to have_one(:workspace).through(:service) }

    it { is_expected.to validate_presence_of(:service) }
    it { is_expected.to validate_presence_of(:task_type) }
  end
end
