class CreateRates < ActiveRecord::Migration[5.1]
  def change
    create_table :rates, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.references  :task_type, null: false
      t.references  :source_language, index: false
      t.references  :target_language, index: false
      t.references  :unit, index: false, null: false

      t.belongs_to  :client, index: false
      t.references  :owner, null: false
      t.belongs_to  :workspace, null: false, index: false

      t.string      :rate_type, null: false
      t.integer     :classification, null: false

      t.decimal     :price, default: 0.0, null: false, precision: 19, scale: 4
      t.string      :currency, null: false, limit: 3

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :rates, :uuid, unique: true
    add_index :rates, [:workspace_id, :rate_type]
  end
end
