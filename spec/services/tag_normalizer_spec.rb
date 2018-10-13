require 'rails_helper'

RSpec.describe TagNormalizer do
  describe '.normalizer' do
    it 'downcases the provided name' do
      expect(TagNormalizer.normalizer.call('Tasty Pancakes')).to eq('tasty pancakes')
    end
  end
end
