class CreateAnnotations < ActiveRecord::Migration[5.2]
  def change
    create_table :annotations, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :annotatable, polymorphic: true, null: false, index: true
      t.belongs_to  :author, polymorphic: true, null: false, index: true
      t.belongs_to  :workspace, null: false

      t.string      :annotation_type, null: false
      t.text        :content, default: ''

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
