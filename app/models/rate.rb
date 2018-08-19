class Rate < ApplicationRecord
  include EnsureUUID

  with_options class_name: 'Language', optional: true do
    belongs_to :source_language, foreign_key: :source_language_id
    belongs_to :target_language, foreign_key: :target_language_id
  end

  belongs_to :task_type
  belongs_to :unit
  belongs_to :client, optional: true
  belongs_to :workspace,
             class_name: '::Workspace',
             foreign_key: :workspace_id,
             inverse_of: :rates

  enum classification: {
    translation: 0,
    interpreting: 1,
    localization: 2,
    other: 3
  }

  discriminate Rate, on: :rate_type

  scope :default_for_client, ->(type) { where(rate_type: :client_default) }
  scope :default_for_contractor, ->(type) { where(rate_type: :contractor_default) }
  scope :for_task, ->(task) {
    where(
      classification: task.classification,
      source_language: task.source_language,
      target_language: task.target_language,
      task_type: task.task_type,
      unit: task.unit
    ).limit(1)
  }

  scope :with_classification, ->(type) { where(classification: type) }
  scope :without_duplicates, -> {
    select('DISTINCT ON (source_language_id, target_language_id, unit_id, task_type_id) *').
    order('source_language_id, target_language_id, unit_id, task_type_id, rate_type')
  }

  before_validation {
    self.classification = task_type&.classification
    self.currency = owner&.currency
  }

  validates :owner, :task_type, :workspace, :unit, presence: true
  validates :source_language, presence: true, if: :language_combination_rate?
  validates :target_language, presence: true, unless: :other_rate?

  delegate :languages, :task_types, :units, to: :workspace, prefix: :applicable
  delegate :unit_type, to: :unit

  def self.set_rate_type(type)
    after_initialize { self.rate_type = type }
  end

  def language_combination_rate?
    return false unless classification
    classification.to_sym.in?([:translation, :interpreting])
  end

  def other_rate?
    return false unless classification
    classification.to_sym == :other
  end

  def self.rate_for(task)
    find_by(task.query_fields)
  end
end
