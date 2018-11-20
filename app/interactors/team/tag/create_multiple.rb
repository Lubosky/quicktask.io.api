class Team::Tag::CreateMultiple < ApplicationInteractor
  object :taggable

  array :tags do
    hash do
      string :name
      string :color, default: nil
    end
  end

  def execute
    transaction do
      collection
    end

    collection
  end

  private

  def collection
    @collection ||= tags_attributes.each do |tag_attributes|
      taggable.tags << Tag.find_or_create(tag_attributes)
    end
  end

  def tags_attributes
    attributes[:tags].each do |tag_attributes|
      tag_attributes.tap do |hash|
        hash[:workspace] = current_workspace
      end
    end
  end
end
