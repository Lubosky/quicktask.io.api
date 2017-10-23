require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#render_rich_text' do
    it 'returns the rendered html for the input markdown' do
      content = 'hello **world**'

      formatted = helper.render_rich_text(content)

      expect(formatted).to eq('<p>hello <strong>world</strong></p>')
    end

    context 'with an empty input' do
      it 'returns an empty string' do
        expect(helper.render_rich_text(nil)).to eq('')
      end
    end
  end
end
