require 'rails_helper'

RSpec.describe Tagged::TagNames do
  describe 'Managing tags via names' do
    let(:workspace) { create(:workspace) }
    let(:contractor) { create(:contractor, workspace: workspace) }

    it 'returns tag names' do
      whitelisted = create(:tag, name: 'whitelisted')

      contractor.tags << whitelisted

      expect(contractor.tag_names).to eq(['whitelisted'])
    end

    it 'adds tags via their names' do
      contractor.tag_names << 'whitelisted'
      contractor.save!

      expect(contractor.tags.collect(&:name)).to eq(['whitelisted'])
    end

    it 'allows for different tag normalisation' do
      TagNormalizer.normalizer = lambda { |name| name.upcase }

      tag = create(:tag, name: 'whitelisted')
      expect(tag.name).to eq('WHITELISTED')

      TagNormalizer.normalizer = nil
    end

    it 'doesn\'t complain when adding an existing tag' do
      contractor.tag_names << 'whitelisted'
      contractor.tag_names << 'whitelisted'
      contractor.save!

      expect(contractor.tags.collect(&:name)).to eq(['whitelisted'])
    end

    it 'accepts a completely new set of tags' do
      contractor.tag_names = %w[ portland retired ]
      contractor.save!

      expect(contractor.tags.collect(&:name)).to eq(%w[ portland retired ])
    end

    it 'does not allow duplication of tags' do
      existing = create(:contractor, workspace: workspace)
      existing.tags << create(:tag, name: 'preferred', workspace: workspace)

      contractor.tag_names = %w[ preferred ]
      contractor.save!

      expect(existing.tag_ids).to eq(contractor.tag_ids)
    end

    it 'appends tag names' do
      contractor.tag_names  = %w[ preferred ]
      contractor.tag_names += %w[ retired ruby ]
      contractor.save!

      expect(contractor.tags.collect(&:name)).to eq(%w[ preferred retired ruby ])
    end

    it 'does not repeat appended names that already exist' do
      contractor.tag_names  = %w[ preferred retired ]
      contractor.tag_names += %w[ retired ruby ]
      contractor.save!

      expect(contractor.tags.collect(&:name)).to eq(%w[ preferred retired ruby ])
    end

    it 'removes a single tag name' do
      contractor.tag_names = %w[ preferred retired ]
      contractor.tag_names.delete 'retired'
      contractor.save!

      expect(contractor.tags.collect(&:name)).to eq(%w[ preferred ])
    end

    it 'removes tag names' do
      contractor.tag_names  = %w[ preferred retired ruby ]
      contractor.tag_names -= %w[ retired ruby ]
      contractor.save!

      expect(contractor.tags.collect(&:name)).to eq(%w[ preferred ])
    end

    it 'matches tag names ignoring case' do
      contractor.tag_names  = %w[ preferred ]
      contractor.tag_names += %w[ Preferred ]
      contractor.save!

      expect(contractor.tags.collect(&:name)).to eq(%w[ preferred ])

      contractor.tag_names << 'Preferred'
      contractor.save!

      expect(contractor.tags.collect(&:name)).to eq(%w[ preferred ])
    end

    it 'allows setting of tag names on unpersisted objects' do
      contractor = build(:contractor, tag_names: %w[ whitelisted blacklisted ])
      contractor.save!

      expect(contractor.tag_names).to eq(%w[ whitelisted blacklisted ])
    end

    it 'returns known tag names from a freshly loaded object' do
      contractor.tag_names << 'whitelisted'
      contractor.save!

      expect(Contractor.find(contractor.id).tag_names).to eq(['whitelisted'])
    end

    it 'ignores blank tags' do
      contractor = build(:contractor, tag_names: ['', 'whitelisted'])
      contractor.save!

      expect(contractor.tag_names).to eq(%w[ whitelisted ])
    end
  end
end
