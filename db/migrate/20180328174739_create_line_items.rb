class CreateLineItems < ActiveRecord::Migration[5.1]
  def change
    create_table :line_items, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :bookkeepable, polymorphic: true, null: false
      t.belongs_to  :workspace, null: false

      t.belongs_to  :source_language, references: :language, index: false
      t.belongs_to  :target_language, references: :language, index: false
      t.belongs_to  :task_type, index: false, null: false
      t.belongs_to  :unit, index: false, null: false

      t.string      :description

      t.float       :quantity, null: false
      t.decimal     :unit_price, null: false, precision: 19, scale: 4

      t.decimal     :discount, default: 0.0, null: false, precision: 6, scale: 5
      t.decimal     :surcharge, default: 0.0, null: false, precision: 6, scale: 5
      t.decimal     :subtotal, default: 0.0, null: false, precision: 19, scale: 4
      t.decimal     :total, default: 0.0, null: false, precision: 19, scale: 4

      t.jsonb       :line_item_data, default: {}

      t.integer     :position

      t.timestamps
      t.datetime    :deleted_at
    end
  end
end
