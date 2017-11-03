require 'rails_helper'

RSpec.describe SlugGenerator do
  describe 'generate' do
    it 'provides a slug for the workspace based on `name` attribute if it exists' do
      workspace = build(:workspace, name: 'nuff said')

      expect(SlugGenerator.slugify(workspace.name)).
        to eq 'nuff-said'
    end

    it 'lowercases a `name` attribute' do
      workspace = build(:workspace, name: 'NUFF SAID')

      expect(SlugGenerator.slugify(workspace.name)).
        to eq 'nuff-said'
    end

    it 'converts non-ASCII characters' do
      workspace = build(:workspace, name: "\'Nüff said!")

      expect(SlugGenerator.slugify(workspace.name)).
        to eq 'nuff-said'
    end

    it 'applies a number-modified name for the workspace if the current one is taken' do
      create(:workspace, slug: 'nuff-said')
      workspace = build(:workspace, name: "Nuff said")

      expect(SlugGenerator.slugify(workspace.name)).
        to eq 'nuff-said-1'
    end
  end
end
