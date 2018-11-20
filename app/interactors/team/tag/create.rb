class Team::Tag::Create < ApplicationInteractor
  object :taggable

  string :name
  string :color, default: nil

  def execute
    transaction do
      unless tag
        errors.merge!(tag.errors)
        rollback
      end

      taggable.tags << tag
    end

    tag
  end

  private

  def tag
    @tag ||= Tag.find_or_create(tag_attributes)
  end

  def tag_attributes
    attributes.slice(:name, :color).tap do |hash|
      hash[:workspace] = current_workspace
    end
  end
end
