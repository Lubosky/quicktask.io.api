require 'rails_helper'

RSpec.describe Workspace, type: :model do
  context 'validations' do
    before do
      Workspace.any_instance.stubs(:ensure_uuid).returns(true)
    end

    subject { create(:workspace) }

    it { is_expected.to belong_to(:owner).class_name('User').with_foreign_key(:owner_id) }

    it { is_expected.to have_many(:charges) }
    it { is_expected.to have_many(:client_contacts) }
    it { is_expected.to have_many(:client_requests) }
    it { is_expected.to have_many(:contractors) }
    it { is_expected.to have_many(:default_client_rates) }
    it { is_expected.to have_many(:default_contractor_rates) }
    it { is_expected.to have_many(:languages) }
    it { is_expected.to have_many(:members).class_name('WorkspaceUser').with_foreign_key(:workspace_id) }
    it { is_expected.to have_many(:project_groups) }
    it { is_expected.to have_many(:projects) }
    it { is_expected.to have_many(:quotes) }
    it { is_expected.to have_many(:rates) }
    it { is_expected.to have_many(:services) }
    it { is_expected.to have_many(:specializations) }
    it { is_expected.to have_many(:supported_currencies).class_name('WorkspaceCurrency').with_foreign_key(:workspace_id) }
    it { is_expected.to have_many(:task_types) }
    it { is_expected.to have_many(:tasklists) }
    it { is_expected.to have_many(:tasks) }
    it { is_expected.to have_many(:team_members) }
    it { is_expected.to have_many(:todos) }
    it { is_expected.to have_many(:units) }

    it { is_expected.to have_one(:membership) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:owner_id) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end

  context '#previously_subscribed?' do
    it 'is true if the workspace has membership but not an active one' do
      workspace = create(:workspace, :with_inactive_membership)
      expect(workspace).to be_previously_subscribed
    end

    it 'is false if the workspace has an active membership' do
      workspace = create(:workspace, :with_membership)
      expect(workspace).to_not be_previously_subscribed
    end

    it 'is false if the workspace has no membership at all' do
      workspace = create(:workspace, membership: nil)
      expect(workspace).to_not be_previously_subscribed
    end
  end

  context '#subscribed?' do
    it 'returns true if the workspace\'s associated membership is active' do
      workspace = Workspace.new
      membership = build_stubbed(:active_membership)
      workspace.expects(:membership).returns(membership).at_least_once

      expect(workspace.subscribed?).to eq(true)
    end

    it 'returns false if the workspace\'s associated membership is not active' do
      workspace = Workspace.new
      membership = build_stubbed(:inactive_membership)
      workspace.expects(:membership).returns(membership).at_least_once

      expect(workspace.subscribed?).to eq(false)
    end

    it 'returns false if the workspace doesn\'t even have a membership' do
      workspace = Workspace.new

      expect(workspace.subscribed?).to eq(false)
    end
  end

  describe '#subscribed_at' do
    it 'returns the date the workspace subscribed if the workspace has a membership' do
      workspace = create(:workspace, :with_membership)

      expect(workspace.subscribed_at).to eq workspace.membership.created_at
    end

    it 'returns nil when the workspace does not have a subscription' do
      workspace = create(:workspace)

      expect(workspace.subscribed_at).to be_nil
    end
  end


  describe '#credit_card' do
    before { StripeMock.start }
    after { StripeMock.stop }

    it 'returns nil if there is no stripe_customer_id' do
      workspace = create(:workspace, stripe_customer_id: '')

      expect(workspace.credit_card).to be_nil
    end

    it 'returns the active card for the stripe customer' do
      stub_stripe_customer
      workspace = create(:workspace, stripe_customer_id: 'customer123')

      expect(workspace.credit_card).not_to be_nil
      expect(workspace.credit_card['last4']).to eq '9090'
    end
  end

  describe '#has_stripe_customer?' do
    before { StripeMock.start }
    after { StripeMock.stop }

    it 'returns false if there is no stripe_customer_id' do
      workspace = build(:workspace, stripe_customer_id: '')

      expect(workspace.has_credit_card?).to eq(false)
    end

    it 'returns true if there is stripe_customer_id' do
      stub_stripe_customer
      workspace = build(:workspace, stripe_customer_id: 'customer123')

      expect(workspace.has_credit_card?).to eq(true)
    end
  end

  describe '#has_credit_card?' do
    it 'returns false if the stripe customer does not have any cards' do
      customer = mock('Stripe::Customer', sources: [])
      Stripe::Customer.expects(:retrieve).returns(customer)
      workspace = build(:workspace, stripe_customer_id: 'customer123')

      expect(workspace).to_not have_credit_card
    end

    it 'returns true if the stripe customer has any cards' do
      customer = mock('Stripe::Customer', sources: [:credit_card])
      Stripe::Customer.expects(:retrieve).returns(customer)
      workspace = build(:workspace, stripe_customer_id: 'customer123')

      expect(workspace).to have_credit_card
    end
  end

  def stripe_customer
    Stripe::Customer.retrieve('customer123')
  end

  def stub_stripe_customer
    card_token = StripeMock.generate_card_token(last4: '9090')

    Stripe::Customer.create(id: 'customer123', source: card_token)
  end
end
