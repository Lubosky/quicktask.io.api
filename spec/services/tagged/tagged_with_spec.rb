require 'rails_helper'

RSpec.describe Tagged::TaggedWith do
  describe '.tagged_with' do
    let(:workspace) { create(:workspace) }
    let!(:whitelisted_contractor) do
      contractor = create(:contractor, workspace: workspace, first_name: 'The Dude')
      contractor.tag_names << 'whitelisted'
      contractor.save!
      contractor
    end

    let!(:preferred_contractor) do
      contractor = create(:contractor, workspace: workspace)
      contractor.tag_names << 'preferred'
      contractor.save!
      contractor
    end

    let!(:whitelisted_preferred_contractor) do
      contractor = create(:contractor, workspace: workspace)
      contractor.tag_names = %w[ whitelisted preferred ]
      contractor.save!
      contractor
    end

    context 'given a single tag name' do
      subject { Contractor.tagged_with(names: 'whitelisted') }

      it { expect(subject.count).to eq 2 }
      it { is_expected.to include whitelisted_contractor, whitelisted_preferred_contractor }
      it { is_expected.not_to include preferred_contractor }
    end

    context 'given a single tag name[symbol]' do
      subject { Contractor.tagged_with(names: :whitelisted) }

      it { expect(subject.count).to eq 2 }
      it { is_expected.to include whitelisted_contractor, whitelisted_preferred_contractor }
      it { is_expected.not_to include preferred_contractor }
    end

    context 'given a denormalized tag name' do
      subject { Contractor.tagged_with(names: 'whitelisted') }

      it { expect(subject.count).to eq 2 }
      it { is_expected.to include whitelisted_contractor, whitelisted_preferred_contractor }
      it { is_expected.not_to include preferred_contractor }
    end

    context 'given multiple tag names' do
      subject { Contractor.tagged_with(names: %w[ whitelisted preferred ]) }

      it { expect(subject.count).to eq 3 }
      it do
        is_expected.to include(
          whitelisted_contractor, preferred_contractor, whitelisted_preferred_contractor
        )
      end
    end

    context 'given an array of tag names' do
      subject { Contractor.tagged_with(names: %w[ whitelisted preferred ]) }

      it { expect(subject.count).to eq 3 }
      it do
        is_expected.to include(
          whitelisted_contractor, preferred_contractor, whitelisted_preferred_contractor
        )
      end
    end

    context 'given a single tag instance' do
      subject do
        Contractor.tagged_with(tags: Tag.find_by_name!('whitelisted'))
      end

      it { expect(subject.count).to eq 2 }
      it { is_expected.to include(whitelisted_contractor, whitelisted_preferred_contractor) }
      it { is_expected.not_to include preferred_contractor }
      it { expect(subject.to_sql).not_to include 'unique_tags' }
    end

    context 'given a single tag id' do
      subject do
        Contractor.tagged_with(ids: Tag.find_by_name!('whitelisted'))
      end

      it { expect(subject.count).to eq 2 }
      it { is_expected.to include(whitelisted_contractor, whitelisted_preferred_contractor) }
      it { is_expected.not_to include preferred_contractor }
      it { expect(subject.to_sql).not_to include 'unique_tags' }
    end

    context 'given multiple tag objects' do
      subject do
        Contractor.tagged_with(
          tags: Tag.where(name: %w[ whitelisted preferred ])
        )
      end

      it { expect(subject.count).to eq 3 }
      it do
        is_expected.to include(
          whitelisted_contractor, preferred_contractor, whitelisted_preferred_contractor
        )
      end
      it { expect(subject.to_sql).not_to include 'unique_tags' }
    end

    context 'chaining where clause' do
      subject do
        Contractor.tagged_with(names: %w[ whitelisted preferred ]).
          where(first_name: 'The Dude')
      end

      it { expect(subject.count).to eq 1 }
      it { is_expected.to include whitelisted_contractor }
      it { is_expected.not_to include preferred_contractor, whitelisted_preferred_contractor }
    end

    context 'appended onto a relation' do
      subject do
        Contractor.where(first_name: 'The Dude').
          tagged_with(names: %w[ whitelisted preferred ])
      end

      it { expect(subject.count).to eq 1 }
      it { is_expected.to include whitelisted_contractor }
      it { is_expected.not_to include preferred_contractor, whitelisted_preferred_contractor }
    end

    context 'matching against all tags' do
      subject do
        Contractor.tagged_with(names: %w[ whitelisted preferred ], match: :all)
      end

      it { expect(subject.count).to eq 1 }
      it { is_expected.to include whitelisted_preferred_contractor }
      it { is_expected.not_to include preferred_contractor, whitelisted_contractor }
    end

    context 'matching against all tag ids' do
      let(:tag_ids) do
        Tag.where(name: %w[ whitelisted preferred ]).pluck(:id)
      end
      subject { Contractor.tagged_with(ids: tag_ids, match: :all) }

      it { expect(subject.count).to eq 1 }
      it { is_expected.to include whitelisted_preferred_contractor }
      it { is_expected.not_to include preferred_contractor, whitelisted_contractor }
    end

    context 'matching against all one tag is the same as any' do
      subject { Contractor.tagged_with(names: %w[ whitelisted ], match: :all) }

      it { expect(subject.count).to eq 2 }
      it { is_expected.to include whitelisted_contractor, whitelisted_preferred_contractor }
      it { is_expected.not_to include preferred_contractor }
    end
  end
end
