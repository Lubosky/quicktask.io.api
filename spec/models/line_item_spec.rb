require 'rails_helper'

RSpec.describe LineItem, type: :model do
  let!(:workspace) { create(:workspace) }
  let!(:client) { create(:client, workspace: workspace) }
  let!(:owner) { create(:team_member, workspace: workspace) }
  let!(:source_language) { create(:language, code: :en, workspace: workspace) }
  let!(:target_language) { create(:language, code: :de, workspace: workspace) }
  let!(:task_type) { create(:task_type, workspace: workspace) }
  let!(:unit) { create(:unit, workspace: workspace) }
  let!(:quote) { create(:quote, client: client, owner: owner, workspace: workspace) }

  subject {
    build(
      :line_item,
      bookkeepable: quote,
      source_language: source_language,
      target_language: target_language,
      task_type: task_type,
      unit: unit,
      workspace: workspace
    )
  }

  context 'validations' do
    before do
      LineItem.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:bookkeepable) }
    it { is_expected.to belong_to(:source_language).class_name('Language').without_validating_presence }
    it { is_expected.to belong_to(:target_language).class_name('Language').without_validating_presence }
    it { is_expected.to belong_to(:task_type) }
    it { is_expected.to belong_to(:unit) }
    it { is_expected.to belong_to(:workspace).without_validating_presence }

    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_presence_of(:unit) }
    it { is_expected.to validate_presence_of(:unit_price) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end

  context 'delegations' do
    before do
      LineItem.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { should delegate_method(:classification).to(:task_type) }
    it { should delegate_method(:unit_type).to(:unit) }
    it { should delegate_method(:workspace).to(:bookkeepable) }
  end

  describe '#language_combination_task?' do
    it 'returns `true` if associated classification is `:translation` or `:interpreting`' do
      task_type = create(:task_type)
      subject.task_type = task_type

      expect(subject.language_combination_task?).to eq true
    end

    it 'returns `false` if rate classification is not `:translation` or `:interpreting`' do
      task_type = create(:task_type, :other)
      subject.task_type = task_type

      expect(subject.language_combination_task?).to eq false
    end
  end

  describe '#other_task?' do
    it 'returns `true` if associated classification is `:other`' do
      task_type = create(:task_type, :other)
      subject.task_type = task_type

      expect(subject.other_task?).to eq true
    end

    it 'returns `false` if rate classification is not `:other`' do
      task_type = create(:task_type, :interpreting)
      subject.task_type = task_type

      expect(subject.other_task?).to eq false
    end
  end

  describe '#calculate_totals' do
    it 'calculates subtotal and total for given line item' do
      subject.unit_price = 20
      subject.quantity = 10
      subject.surcharge = 10
      subject.discount = 5

      subject.calculate_totals

      expect(subject.subtotal).to eq 200
      expect(subject.total).to eq 210
    end
  end
end
