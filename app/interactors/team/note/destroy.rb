class Team::Note::Destroy < ApplicationInteractor
  object :note

  def execute
    note.destroy
  end
end
