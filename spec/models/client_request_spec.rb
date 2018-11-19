require 'rails_helper'

RSpec.describe ClientRequest, type: :model do
  let!(:workspace) { create(:workspace) }
  let!(:client) { create(:client, workspace: workspace) }
  let!(:owner) {
    create(
      :workspace_account,
      :with_client,
      workspace: workspace,
      role: Role::Client.create(name: 'Client', workspace: workspace)
    )
  }
  let!(:service) { create(:service, workspace: workspace) }
  let!(:unit) { create(:unit, workspace: workspace) }

  subject {
    ClientRequest.new(
      workspace: workspace,
      client: client,
      owner: owner,
      service: service,
      unit: unit
    )
  }

  context 'validations' do
    before do
      ClientRequest.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:owner).class_name('WorkspaceAccount') }
    it { is_expected.to belong_to(:service) }
    it { is_expected.to belong_to(:source_language).class_name('Language') }
    it { is_expected.to belong_to(:unit) }
    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to have_one(:proposal) }
    it { is_expected.to have_one(:quote).through(:proposal) }
    it { is_expected.to have_one(:specialization_relation) }
    it { is_expected.to have_one(:specialization).through(:specialization_relation) }

    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_presence_of(:exchange_rate) }
    it { is_expected.to validate_presence_of(:owner) }
    it { is_expected.to validate_presence_of(:request_type) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:due_date) }
    it { is_expected.to validate_presence_of(:unit) }
    it { is_expected.to validate_presence_of(:unit_count) }
    it { is_expected.to validate_presence_of(:workspace) }
    it { is_expected.to validate_presence_of(:workspace_currency) }
  end
end
