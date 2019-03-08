require 'rails_helper'

RSpec.describe Tagging, type: :model do
  subject { create(:tagging) }

  context 'validations' do
    before do
      Tagging.any_instance.stubs(:ensure_uuid).returns(true)
    end

    it { is_expected.to belong_to(:workspace).without_validating_presence }
    it { is_expected.to belong_to(:taggable) }
    it { is_expected.to belong_to(:tag) }
  end

  describe "#valid?" do
    let(:workspace) { create(:workspace) }
    let(:tag) { Tag.create!(name: 'pancakes', workspace: workspace) }
    let(:taggable) { create(:task) }

    it 'ensures tags are unique for any given taggable' do
      tagging = Tagging.new
      tagging.tag = tag
      tagging.taggable = taggable
      tagging.save!

      tagging = Tagging.new
      tagging.tag = tag
      tagging.taggable = taggable

      tagging.valid?
      expect(tagging.errors[:tag_id].length).to eq(1)
    end
  end
end
