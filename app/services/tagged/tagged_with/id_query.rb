class Tagged::TaggedWith::IDQuery < Tagged::TaggedWith::Query
  private

  def taggable_ids_query
    Tagging.select(:taggable_id).
      where(taggable_type: model.base_class.name).
      where(tag_id: values)
  end
end
