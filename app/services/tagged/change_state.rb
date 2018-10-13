class Tagged::ChangeState
  attr_reader :taggable
  attr_writer :normalizer

  def initialize(taggable)
    @taggable = taggable
    @existing = normalized taggable.tags.collect(&:name)
    @changes = normalized taggable.tag_names
  end

  def added
    @added ||= changes - existing
  end

  def removed
    @removed ||= existing - changes
  end

  private

  attr_reader :existing, :changes

  def normalized(values)
    values.collect { |value| normalizer.call(value) }.uniq
  end

  def normalizer
    @normalizer ||= proc { |value| TagNormalizer.normalizer.call(value) }
  end
end
