class Language < ApplicationRecord
  include EnsureUUID

  belongs_to :workspace, inverse_of: :languages

  validates :code,
            presence: true,
            uniqueness: { scope: :workspace_id }
  validate :validate_supported_language

  def self.build_for(workspace)
    workspace.languages.build(fixtures)
  end

  def self.create_for(workspace)
    workspace.languages.create(fixtures)
  end

  def self.fixtures
    YAML.load_file(Rails.root.join('config', 'fixtures', 'languages.yml'))
  end

  private

  def validate_supported_language
    unless Config::Language.exists?(id: code)
      errors.add(:code, :invalid)
      throw(:abort)
    end
  end
end
