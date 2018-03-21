require 'rails_helper'

RSpec.describe ClientRequest, type: :model do
  context 'validations' do
    before do
      ClientRequest.any_instance.stubs(:currency).returns(:jpy)
      ClientRequest.any_instance.stubs(:workspace_currency).returns(:usd)
    end

    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:owner).class_name('WorkspaceUser') }
    it { is_expected.to belong_to(:service) }
    it { is_expected.to belong_to(:unit) }
    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to have_one(:specialization_relation) }
    it { is_expected.to have_one(:specialization).through(:specialization_relation) }
  end
end
