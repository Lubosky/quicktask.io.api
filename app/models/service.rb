class Service < ApplicationRecord
  include EnsureUUID

  belongs_to :workspace, inverse_of: :services

  enum classification: {
    translation: 0,
    interpreting: 1,
    localization: 2,
    other: 3
  }

  scope :with_type, ->(classification) { where(classification: classification) }

  validates_presence_of :name, :classification
  validates_uniqueness_of :name, case_sensitive: false, scope: :workspace_id

  after_initialize :set_default_attributes, on: :create

  private

  def set_default_attributes
    self.classification ||= :translation
  end
end
