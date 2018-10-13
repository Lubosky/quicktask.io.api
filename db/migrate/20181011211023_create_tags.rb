class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false

      t.string      :name, null: false
      t.integer     :color
      t.integer     :tagging_count, default: 0, null: false

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :tags, :name
    add_index :tags, %i[ workspace_id name deleted_at ], unique: true
  end
end
