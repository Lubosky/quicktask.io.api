class Tagged::TaggedWith::NameQuery < Tagged::TaggedWith::Query
  def initialize(model, values, match)
    super

    @values = @values.collect { |tag| TagNormalizer.normalizer.call(tag) }
  end

  private

  def taggable_ids_query
    Tagging.joins(:tag).select(:taggable_id).
      where(taggable_type: model.base_class.name).
      where(tags: { name: values })
  end
end
