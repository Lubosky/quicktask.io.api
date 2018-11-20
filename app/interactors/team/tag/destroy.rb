class Team::Tag::Destroy < ApplicationInteractor
  object :tag

  def execute
    tag.destroy
  end
end
