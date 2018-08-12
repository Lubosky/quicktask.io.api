class CreatePurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_orders, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.references  :owner, polymorphic: true, null: false
      t.belongs_to  :issuer, references: :team_member, index: false, null: false
      t.belongs_to  :updater, references: :team_member, index: false
      t.belongs_to  :hand_off, null: false
      t.belongs_to  :workspace, null: false

      t.string      :subject, null: false
      t.string      :identifier

      t.string      :purchase_order_number
      t.jsonb       :purchase_order_data

      t.datetime    :issue_date

      t.boolean     :billed, default: false, null: false

      t.jsonb       :currency_data, default: {}
      t.jsonb       :metadata, default: {}

      t.decimal     :discount, default: 0.0, null: false, precision: 19, scale: 4
      t.decimal     :surcharge, default: 0.0, null: false, precision: 19, scale: 4
      t.decimal     :subtotal, default: 0.0, null: false, precision: 19, scale: 4
      t.decimal     :total, default: 0.0, null: false, precision: 19, scale: 4

      t.text        :notes
      t.text        :terms

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :purchase_orders, :uuid, unique: true
  end
end
