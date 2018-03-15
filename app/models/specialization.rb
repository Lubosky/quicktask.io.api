class Specialization < ApplicationRecord
  include EnsureUUID

  belongs_to :workspace, inverse_of: :specializations

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false, scope: :workspace_id


  def self.build_for(workspace)
    workspace.specializations.build(fixtures)
  end

  def self.create_for(workspace)
    workspace.specializations.create(fixtures)
  end

  def self.fixtures
    YAML.load_file(Rails.root.join('config', 'fixtures', 'specializations.yml'))
  end
end
