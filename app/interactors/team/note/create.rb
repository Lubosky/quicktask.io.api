class Team::Note::Create < ApplicationInteractor
  object :annotatable

  string :content

  def execute
    transaction do
      unless note.save
        errors.merge!(note.errors)
        rollback
      end
    end
    note
  end

  private

  def note
    @note ||= annotatable.notes.build(note_attributes)
  end

  def note_attributes
    attributes.tap do |hash|
      hash[:author] = current_account.account
    end
  end
end
