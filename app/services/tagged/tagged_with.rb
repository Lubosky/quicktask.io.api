class Tagged::TaggedWith
  def self.call(model, options)
    new(model, options).call
  end

  def initialize(model, options)
    @model = model
    @options = options
  end

  def call
    query_class.new(model, values, match).call
  end

  private

  attr_reader :model, :options

  def match
    options[:match] || :any
  end

  def query_class
    options[:names] ? NameQuery : IDQuery
  end

  def values
    if options[:tags]
      Array(options[:tags]).collect(&:id)
    else
      options[:ids] || options[:names]
    end
  end
end
