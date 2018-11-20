class Team::Tag::Update < ApplicationInteractor
  object :tag

  string :name, default: nil
  string :color, default: nil

  def execute
    transaction do
      unless tag.update(given_attributes.except(:tag))
        errors.merge!(tag.errors)
        rollback
      end
    end
    tag
  end
end
