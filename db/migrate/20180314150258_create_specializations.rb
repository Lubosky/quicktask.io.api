class CreateSpecializations < ActiveRecord::Migration[5.1]
  def change
    create_table :specializations, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false

      t.string      :name, null: false
      t.boolean     :default, default: false, null: false

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :specializations, :uuid, unique: true
  end
end
