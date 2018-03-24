class Unit < ApplicationRecord
  include EnsureUUID

  belongs_to :workspace, inverse_of: :units

  enum unit_type: { volume: 0, time: 1, percentage: 2, fixed: 3 }

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false, scope: :workspace_id

  after_initialize :set_default_attributes, on: :create

  def self.build_for(workspace)
    workspace.units.build(fixtures)
  end

  def self.create_for(workspace)
    workspace.units.create(fixtures)
  end

  def self.fixtures
    YAML.load_file(Rails.root.join('config', 'fixtures', 'units.yml'))
  end

  private

  def set_default_attributes
    self.unit_type ||= :volume
  end
end
