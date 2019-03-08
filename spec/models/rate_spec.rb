require 'rails_helper'

RSpec.describe Rate, type: :model do
  subject { create_rate }

  context 'validations' do
    it { is_expected.to belong_to(:source_language).
      class_name('Language').
      with_foreign_key(:source_language_id).without_validating_presence
    }
    it { is_expected.to belong_to(:target_language).
      class_name('Language').
      with_foreign_key(:target_language_id).without_validating_presence
    }
    it { is_expected.to belong_to(:task_type) }
    it { is_expected.to belong_to(:unit) }
    it { is_expected.to belong_to(:workspace).without_validating_presence }

    it { is_expected.to validate_presence_of(:task_type) }
    it { is_expected.to validate_presence_of(:unit) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end

  context 'delegations' do
    it { should delegate_method(:applicable_languages).to(:workspace).as(:languages) }
    it { should delegate_method(:applicable_task_types).to(:workspace).as(:task_types) }
    it { should delegate_method(:applicable_units).to(:workspace).as(:units) }
    it { should delegate_method(:unit_type).to(:unit).as(:unit_type) }
  end

  context 'scopes' do
    describe '.with_classification' do
      it 'returns the rate with the given classification' do
        translation_rate = create_rate(task: :translation)
        localization_rate = create_rate(task: :localization)
        interpreting_rate = create_rate(task: :interpreting)

        expect(Rate.with_classification(:translation)).to eq [translation_rate]
      end
    end
  end

  context 'scopes' do
    describe '.without_duplicates' do
      it 'returns the rates unique by source_language, target_language, task_type, unit' do
        translation_rate = create_rate(task: :translation)
        localization_rate = create_rate(task: :localization)
        interpreting_rate = create_rate(task: :interpreting)
        [translation_rate, localization_rate, interpreting_rate].each do |rate|
          rate.dup.tap do |clone|
            clone[:uuid] = nil
            clone.save
          end
        end

        collection = Rate.without_duplicates

        expect(collection.map(&:classification)).to eq ['translation', 'localization', 'interpreting']
        expect(collection.size).to eq 3
      end
    end
  end

  describe '#language_combination_rate?' do
    it 'returns `true` if rate classification is `:translation` or `:interpreting`' do
      translation_rate = Rate.new(classification: :translation)
      interpreting_rate = Rate.new(classification: :interpreting)

      expect(translation_rate.language_combination_rate?).to eq true
      expect(interpreting_rate.language_combination_rate?).to eq true
    end

    it 'returns `false` if rate classification is not `:translation` or `:interpreting`' do
      rate = Rate.new(classification: :localization)

      expect(rate.language_combination_rate?).to eq false
    end
  end

  describe '#other_rate?' do
    it 'returns `true` if rate classification is `:other`' do
      rate = Rate.new(classification: :other)

      expect(rate.other_rate?).to eq true
    end

    it 'returns `false` if rate classification is not `:other`' do
      rate = Rate.new(classification: :translation)

      expect(rate.other_rate?).to eq false
    end
  end

  def create_rate(owner: nil, workspace: nil, task: :translation, source: :en, target: :de, unit: 'word', default: false, type: :client)
    workspace = workspace || create(:workspace)
    if default
      owner = workspace
    else
      owner = owner || create(:client, workspace: workspace)
    end
    source_language = create(:language, code: source, workspace: workspace)
    target_language = create(:language, code: target, workspace: workspace)
    task_type = create(:task_type, classification: task, workspace: workspace)
    unit = create(:unit, workspace: workspace)

    if default
      klass = "Rate::Workspace::#{type.to_s.camelize}".constantize
    else
      klass = "Rate::#{owner.class.to_s}".constantize
    end

    klass.create(
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
