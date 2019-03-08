require 'rails_helper'

RSpec.describe ClientRequest, type: :model do
  let!(:workspace) { create(:workspace) }
  let!(:client) { create(:client, workspace: workspace) }
  let!(:requester) {
    account = create(
      :workspace_account,
      :with_client,
      workspace: workspace,
      role: Role::Client.create(name: 'Client', workspace: workspace)
    )

    account&.profile
  }
  let!(:service) { create(:service, workspace: workspace) }
  let!(:unit) { create(:unit, workspace: workspace) }

  subject {
    ClientRequest.new(
      workspace: workspace,
      client: client,
      requester: requester,
      service: service,
      unit: unit
    )
  }

  context 'validations' do
    before do
      ClientRequest.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:requester).class_name('ClientContact') }
    it { is_expected.to belong_to(:service).without_validating_presence }
    it { is_expected.to belong_to(:source_language).class_name('Language').optional }
    it { is_expected.to belong_to(:unit).optional }
    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to have_one(:proposal) }
    it { is_expected.to have_one(:quote).through(:proposal) }
    it { is_expected.to have_one(:specialization_relation) }
    it { is_expected.to have_one(:specialization).through(:specialization_relation) }

    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_presence_of(:exchange_rate) }
    it { is_expected.to validate_presence_of(:requester) }
    it { is_expected.to validate_presence_of(:request_type) }
    it { is_expected.to validate_presence_of(:workspace) }
    it { is_expected.to validate_presence_of(:workspace_currency) }
  end
end
