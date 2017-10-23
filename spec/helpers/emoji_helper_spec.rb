require 'rails_helper'

RSpec.describe EmojiHelper do
  let(:normal) { 'You have lovely hands. Do you moisturize?' }
  let(:with_shortcode) { ':sad_noodle:' }
  let(:with_emoji) { ':heart:' }

  describe '#emojify' do
    it 'renders text normally' do
      expect(emojify(normal)).to match normal
    end

    it 'renders absolute urls for emojis' do
      expect(emojify(with_emoji)).to include 'https://'
    end

    it 'emojifies shortcodes with corresponding emoji' do
      expect(emojify(with_emoji)).to match /img/
    end

    it 'does not emojify non-shortcodes' do
      expect(emojify(with_shortcode)).to eq with_shortcode
    end
  end

  def emojify(content)
    helper.emojify(content)
  end
end
