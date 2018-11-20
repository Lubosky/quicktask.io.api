class Tag < ApplicationRecord
  include EnsureUUID

  TAGGABLE_TYPES = ['Client', 'Contractor', 'Task'].freeze

  belongs_to :workspace, inverse_of: :tags

  has_many :taggings, dependent: :destroy

  enum color: [
    :red,
    :orange,
    :yellow_orange,
    :yellow,
    :yellow_green,
    :green,
    :blue_green,
    :aqua,
    :blue,
    :indigo,
    :purple,
    :magenta,
    :hot_pink,
    :pink,
    :cool_gray
  ]

  scope :by_weight, -> { order(tagging_count: :desc) }

  validates :name, :workspace, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: :workspace_id }

  def self.find_by_name(name)
    where(name: TagNormalizer.normalizer.call(name)).first
  end

  def self.find_by_name_and_workspace(name, workspace)
    where(
      workspace: workspace,
      name: TagNormalizer.normalizer.call(name)).first
  end

  def self.find_or_create(color: :cool_gray, name:, workspace:)
    find_by_name_and_workspace(name, workspace) ||
      create(workspace: workspace, name: name, color: color)
  end

  def name=(name)
    super(TagNormalizer.normalizer.call(name))
  end
end
