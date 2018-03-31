class CreateQuotes < ActiveRecord::Migration[5.1]
  def change
    create_table :quotes, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :client
      t.belongs_to  :owner, references: :workspace_user, index: false
      t.belongs_to  :workspace, null: false

      t.string      :quote_type, null: false

      t.string      :subject, null: false
      t.string      :identifier

      t.string      :purchase_order_number
      t.jsonb       :purchase_order_data

      t.integer     :status
      t.datetime    :issue_date
      t.datetime    :expiry_date

      t.datetime    :start_date
      t.datetime    :due_date

      t.boolean     :billed, default: false, null: false

      t.jsonb       :quote_data, default: {}
      t.jsonb       :currency_data, default: {}
      t.jsonb       :settings, default: {}
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

    add_index :quotes, :uuid, unique: true
    add_index :quotes, [:quote_type, :workspace_id]
  end
end
