class Annotation < ApplicationRecord
  include BelongsDirectly, EnsureUUID

  discriminate Annotation, on: :annotation_type

  with_options polymorphic: true do
    belongs_to :annotatable
    belongs_to :author
  end

  has_one :workspace, through: :author

  belongs_directly_to :workspace, foreign_key: :workspace_id

  validates :annotatable, :author, :content, presence: true

  delegate :workspace, to: :author

  def self.set_annotation_type(type)
    after_initialize { self.annotation_type = type }
  end
end
