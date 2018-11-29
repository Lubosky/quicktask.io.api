class Note < Annotation
  set_annotation_type :note

  scope :with_default_order, -> { order(created_at: :desc) }
end
