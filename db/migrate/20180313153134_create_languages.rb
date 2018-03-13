class CreateLanguages < ActiveRecord::Migration[5.1]
  def change
    create_table :languages, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false

      t.string      :code, null: false
      t.string      :name, null: false

      t.boolean     :preferred, default: false, null: false

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :languages, :uuid, unique: true
    add_index :languages, [:code, :workspace_id]
  end
end
