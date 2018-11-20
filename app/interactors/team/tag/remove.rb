class Team::Tag::Remove < ApplicationInteractor
  object :taggable

  integer :tag_id

  def execute
    transaction do
      return nil unless tag

      taggable.tags.delete(tag)
    end

    tag
  end

  private

  def tag
    @tag ||= current_workspace.tags.find_by(id: tag_id)
  end
end
