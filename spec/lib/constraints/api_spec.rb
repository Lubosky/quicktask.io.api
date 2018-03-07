require 'rails_helper'
require 'lib/constraints/api'

RSpec.describe Constraints::API do
  let(:api_v1) { Constraints::API.new(version: 1) }
  let(:api_v2) { Constraints::API.new(version: 2, default: true) }

  describe '#matches?' do
    context 'when the version matches the \'Accept\' header' do
      it 'returns true' do
        request = stub(host: 'backend.gliderpath.test',
                       headers: { 'Accept' => 'application/vnd.gliderpath.v1+json' })

        expect(api_v1.matches?(request)).to be true
      end
    end

    context 'when \'default\' option is specified' do
      it 'returns the default version' do
        request = stub(host: 'backend.gliderpath.test')

        expect(api_v2.matches?(request)).to be true
      end
    end

    context 'when default option is not specified and there are no headers' do
      it 'returns false' do
        request = stub(host: 'backend.gliderpath.test')

        expect(api_v1.matches?(request)).to be false
      end
    end
  end
end
