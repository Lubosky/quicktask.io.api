class UrlBuilder
  def initialize(template)
    @template = Addressable::Template.new(template)
  end

  def expand(params)
    absolute_url(template.expand(params))
  end

  def absolute_url(path)
    URI.join(host, path).to_s
  end

  def host
    Settings.client.url
  end

  def self.template_defines_url?(template, url)
    url_object = Addressable::URI.parse(url)
    template_object = Addressable::Template.new(template)
    url_params = template_object.extract(url_object) || {}

    template_object.expand(url_params) == url_object
  end

  private

  attr_reader :template
end
