class CreateOrganizationCurrencies < ActiveRecord::Migration[5.1]
  def change
    create_table :organization_currencies, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false

      t.string      :code, null: false
      t.decimal     :exchange_rate, null: false, default: 1.0, precision: 22, scale: 11

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :organization_currencies, :uuid, unique: true
    add_index :organization_currencies, [:code, :workspace_id]
  end
end
