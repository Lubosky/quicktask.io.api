class Team::Note::Update < ApplicationInteractor
  object :note

  string :content, default: nil

  def execute
    transaction do
      unless note.update(given_attributes.except(:note))
        errors.merge!(note.errors)
        rollback
      end
    end
    tag
  end
end
