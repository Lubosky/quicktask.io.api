require 'rails_helper'

RSpec.describe HandOff, type: :model do
  subject { build(:hand_off) }

  context 'validations' do
    before do
      HandOff.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:task) }
    it { is_expected.to belong_to(:assignee) }
    it { is_expected.to belong_to(:assigner).class_name('TeamMember') }
    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to validate_presence_of(:assignee) }
    it { is_expected.to validate_presence_of(:assigner) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end

  context '#accepted?' do
    it 'returns true if the hand-off has been accepted' do
      hand_off = build(:hand_off, :accepted)

      expect(hand_off.accepted?).to eq(true)
    end

    it 'returns false if the hand-off\'s `accepted_at` attribute is nil' do
      hand_off = build(:hand_off)

      expect(hand_off.accepted?).to eq(false)
      expect(hand_off.pending?).to eq(true)
    end
  end

  context '#rejected?' do
    it 'returns true if the hand-off has been rejected' do
      hand_off = build(:hand_off, :rejected)

      expect(hand_off.rejected?).to eq(true)
    end

    it 'returns false if the hand-off\'s `rejected_at` attribute is nil' do
      hand_off = build(:hand_off)

      expect(hand_off.rejected?).to eq(false)
      expect(hand_off.pending?).to eq(true)
    end
  end

  context '#cancelled?' do
    it 'returns true if the hand-off has been cancelled' do
      hand_off = build(:hand_off, :cancelled)

      expect(hand_off.cancelled?).to eq(true)
    end

    it 'returns false if the hand-off\'s `cancelled_at` attribute is nil' do
      hand_off = build(:hand_off)

      expect(hand_off.cancelled?).to eq(false)
      expect(hand_off.pending?).to eq(true)
    end
  end

  context '#expired?' do
    it 'returns true if the hand-off has expired' do
      hand_off = build(:hand_off, :expired)

      expect(hand_off.expired?).to eq(true)
    end

    it 'returns true if the hand-off\'s attribute `valid_through` is in the past?' do
      hand_off = build(:hand_off, valid_through: Time.current.yesterday)

      expect(hand_off.expired?).to eq(true)
    end

    it 'returns false if the hand-off\'s attributes `expired_at` and `valid_through` are nil ' do
      hand_off = build(:hand_off)

      expect(hand_off.expired?).to eq(false)
      expect(hand_off.pending?).to eq(true)
    end
  end

  context '#pending?' do
    it 'returns true if the hand-off hasn\'t been accepted/rejected/cancelled/expired' do
      hand_off = build(:hand_off)

      expect(hand_off.pending?).to eq(true)
    end
  end
end
