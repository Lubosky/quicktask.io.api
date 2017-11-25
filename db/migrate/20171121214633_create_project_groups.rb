class CreateProjectGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :project_groups, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :client, null: false
      t.belongs_to  :workspace, null: false

      t.string      :name, null: false

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :project_groups, :uuid, unique: true
  end
end
