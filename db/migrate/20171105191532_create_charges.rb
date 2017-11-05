class CreateCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :charges, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false
      t.string      :stripe_charge_id
      t.string      :stripe_invoice_id

      t.decimal     :amount, default: 0.0, null: false
      t.string      :description
      t.date        :paid_through_date
      t.jsonb       :source, default: {}

      t.timestamps
    end
  end
end
