class Tagging < ApplicationRecord
  include BelongsDirectly, EnsureUUID

  belongs_to :taggable, polymorphic: true
  belongs_to :tag, class_name: 'Tag'
  belongs_to :workspace, inverse_of: :taggings

  belongs_directly_to :workspace

  validates :taggable, :tag, :workspace, presence: true
  validates :tag_id, uniqueness: { scope: %i[ taggable_id taggable_type ] }

  counter_culture :tag, column_name: :tagging_count, touch: true

  delegate :workspace, to: :taggable, allow_nil: true
end
