class CreateTaggings < ActiveRecord::Migration[5.2]
  def change
    create_table :taggings, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false

      t.belongs_to  :tag, null: false
      t.references  :taggable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :taggings, %i[ taggable_type taggable_id tag_id ]
    add_index :taggings,
              %i[ workspace_id taggable_type taggable_id tag_id ],
              unique: true,
              name: 'index_unique_taggings'
  end
end
