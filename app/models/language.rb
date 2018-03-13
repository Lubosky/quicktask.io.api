class Language < ApplicationRecord
  include EnsureUUID

  LANGUAGE_CODES = Config::Language.codes.freeze

  belongs_to :workspace, inverse_of: :languages

  validates :code,
            inclusion: LANGUAGE_CODES,
            presence: true,
            uniqueness: { scope: :workspace_id }

  def self.build_for(workspace)
    workspace.languages.build(fixtures)
  end

  def self.create_for(workspace)
    workspace.languages.create(fixtures)
  end

  def self.fixtures
    YAML.load_file(Rails.root.join('config', 'fixtures', 'languages.yml'))
  end
end
