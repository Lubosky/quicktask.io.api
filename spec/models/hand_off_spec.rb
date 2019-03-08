require 'rails_helper'

RSpec.describe HandOff, type: :model do
  let!(:workspace) { create(:workspace) }
  let!(:contractor) { create(:contractor, workspace: workspace) }
  let!(:rate) { create_rate(owner: contractor, workspace: workspace) }
  let!(:task) {
    create(
      :task,
      workspace: workspace,
      source_language: rate.source_language,
      target_language: rate.target_language,
      task_type: rate.task_type,
      unit: rate.unit
    )
  }

  subject {
    create(
      :hand_off,
      assignee: contractor,
      task: task,
      workspace: workspace
    )
  }

  context 'validations' do
    before do
      HandOff.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:task) }
    it { is_expected.to belong_to(:assignee) }
    it { is_expected.to belong_to(:assigner).class_name('TeamMember') }
    it { is_expected.to belong_to(:workspace).without_validating_presence }

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

  def create_rate(owner: nil, workspace: nil, task: :translation, source: :en, target: :de, unit: 'word')
    workspace = workspace.nil? ? create(:workspace) : workspace
    owner = owner.nil? ? create(:contractor, workspace: workspace) : owner
    source_language = create(:language, code: source, workspace: workspace)
    target_language = create(:language, code: target, workspace: workspace)
    task_type = create(:task_type, classification: task, workspace: workspace)
    unit = create(:unit, workspace: workspace)

    Rate::Contractor.create(
      task_type: task_type,
      source_language: source_language,
      target_language: target_language,
      unit: unit,
      price: rand(100),
      owner: owner,
      workspace: workspace
    )
  end
end
