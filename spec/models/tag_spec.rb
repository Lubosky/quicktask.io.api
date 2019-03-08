require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:workspace) { create(:workspace) }
  subject { create(:tag) }

  context 'validations' do
    before do
      Tag.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace) }

    it { is_expected.to validate_presence_of(:workspace) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity.scoped_to(:workspace_id) }
    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid) }
  end

  describe '.find_by_name_and_workspace' do
    it 'returns a tag with the same name' do
      existing = Tag.create!(name: 'pancakes', workspace: workspace)

      expect(Tag.find_by_name_and_workspace('pancakes', workspace)).to eq(existing)
    end

    it 'returns a tag with the same normalized name' do
      existing = Tag.create!(name: 'pancakes', workspace: workspace)

      expect(Tag.find_by_name_and_workspace('Pancakes', workspace)).to eq(existing)
    end

    it 'otherwise returns nil' do
      expect(Tag.find_by_name_and_workspace('pancakes', workspace)).to be_nil
    end
  end

  describe '.find_or_create' do
    it 'returns a tag with the same name' do
      existing = Tag.create!(name: 'pancakes', workspace: workspace)

      expect(Tag.find_or_create(name: 'pancakes', workspace: workspace)).to eq(existing)
    end

    it 'returns a tag with the same normalized name' do
      existing = Tag.create!(name: 'pancakes', workspace: workspace)

      expect(Tag.find_or_create(name: 'Pancakes', workspace: workspace)).to eq(existing)
    end

    it 'creates a new tag if no matches exist' do
      expect(Tag.find_or_create(name: 'pancakes', workspace: workspace)).to be_persisted
    end
  end

  describe '#name' do
    it 'saves the normalized name' do
      TagNormalizer.normalizer.stubs(:call).returns('waffles')

      expect(Tag.create!(name: 'Pancakes', workspace: workspace).name).to eq('waffles')
    end
  end

  describe '#valid?' do
    it 'ignores case when enforcing uniqueness' do
      Tag.create!(name: 'pancakes', workspace: workspace)

      tag = Tag.create(name: 'Pancakes', workspace: workspace)
      expect(tag.errors[:name].length).to eq(1)
    end

    it 'does not validate the length if the column has no limit' do
      tag = Tag.create(name: 'a' * 256)
      expect(tag.errors[:name].length).to eq(0)
    end
  end

  describe 'Adding and removing tags' do
    let(:workspace)  { create(:workspace) }
    let(:contractor)  { create(:contractor, workspace: workspace) }
    let(:pancakes) { create(:tag, name: 'pancakes', workspace: workspace) }

    it 'stores new tags' do
      contractor.tags << pancakes

      expect(contractor.tags.reload).to eq([pancakes])
    end

    it 'removes existing tags' do
      contractor.tags << pancakes

      contractor.tags.delete pancakes

      expect(contractor.tags.reload).to eq([])
    end

    it 'removes taggings when an contractor is deleted' do
      contractor.tags << pancakes

      contractor.destroy

      expect(Tagging.where(
        taggable_type: 'Contractor', taggable_id: contractor.id
      ).count).to be_zero
    end

    it 'removes taggings when a tag is deleted' do
      contractor.tags << pancakes

      pancakes.destroy

      expect(Tagging.where(tag_id: pancakes.id).count).to be_zero
    end

    it 'should have a mean tag cloud' do
      gorillas = create(:tag, name: 'gorillas', workspace: workspace)
      another_contractor = create(:contractor, workspace: workspace)

      contractor.tags << pancakes
      expect(Tag.by_weight.first).to eq(pancakes)

      contractor.tags << gorillas
      another_contractor.tags << gorillas
      expect(Tag.by_weight.first).to eq(gorillas)
    end
  end
end
