class CreateUnits < ActiveRecord::Migration[5.1]
  def change
    create_table :units, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false

      t.integer     :unit_type
      t.string      :name, null: false

      t.boolean     :deletable, default: true, null: false
      t.boolean     :internal, default: false, null: false
      t.boolean     :preferred, default: false, null: false

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :units, :uuid, unique: true
  end
end
