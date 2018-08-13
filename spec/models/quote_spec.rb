require 'rails_helper'

RSpec.describe Quote, type: :model do
  subject { Quote.new }

  context 'validations' do
    before do
      Quote.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:owner).class_name('TeamMember') }
    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to have_many(:line_items) }

    it { is_expected.to have_one(:proposal) }
    it { is_expected.to have_one(:client_request).through(:proposal) }
    it { is_expected.to have_one(:project_estimate) }
    it { is_expected.to have_one(:project).through(:project_estimate) }

    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_presence_of(:exchange_rate) }
    it { is_expected.to validate_presence_of(:owner) }
    it { is_expected.to validate_presence_of(:workspace) }
    it { is_expected.to validate_presence_of(:workspace_currency) }
  end

  describe '#accepted?' do
    it 'returns true if status is is set to accepted' do
      subject.status = :accepted
      expect(subject).to be_accepted
    end

    it 'returns true if status is is different than accepted' do
      subject.status = :draft
      expect(subject).not_to be_accepted
    end
  end

  describe '#cancelled?' do
    it 'returns true if status is is set to cancelled' do
      subject.status = :cancelled
      expect(subject).to be_cancelled
    end

    it 'returns true if status is is different than cancelled' do
      subject.status = :draft
      expect(subject).not_to be_cancelled
    end
  end

  describe '#declined?' do
    it 'returns true if status is is set to declined' do
      subject.status = :declined
      expect(subject).to be_declined
    end

    it 'returns true if status is is different than declined' do
      subject.status = :draft
      expect(subject).not_to be_declined
    end
  end

  describe '#expired?' do
    it 'returns true if status is is set to expired' do
      subject.status = :expired
      expect(subject).to be_expired
    end

    it 'returns true if status is is different than expired' do
      subject.status = :draft
      expect(subject).not_to be_expired
    end
  end

  describe '#sent?' do
    it 'returns true if status is is set to sent' do
      subject.status = :sent
      expect(subject).to be_sent
    end

    it 'returns true if status is is different than sent' do
      subject.status = :draft
      expect(subject).not_to be_sent
    end
  end
end
