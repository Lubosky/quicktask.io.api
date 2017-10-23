require 'rails_helper'

RSpec.describe UrlBuilder do
  let(:params) do
    { project_id: 999, tasklist_id: 99, params: { page: 9, sort: :desc } }
  end

  let(:template) { '/projects/{project_id}/tasklists/{tasklist_id}/tasks{?params*}' }

  subject { described_class.new(template) }

  describe '::template_defines_url?' do
    it 'returns true if the url matches the template' do
      expect(described_class.template_defines_url?('/a_resource/{id}', '/a_resource/test')).to be true
    end

    it 'returns false if the url does not match the template' do
      expect(described_class.template_defines_url?('/a_resource/{id}', '/a_resourcetest')).to be false
    end
  end

  describe '#expand' do
    before do
      subject.expects(:host).returns('https://api.gliderpath.dev')
    end

    it 'returns the right url' do
      expect(subject.expand(params))
        .to eq('https://api.gliderpath.dev/projects/999/tasklists/99/tasks?page=9&sort=desc')
    end
  end
end
