class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false

      t.boolean     :internal, default: false, null: false

      t.string      :name, null: false
      t.string      :email
      t.string      :phone

      t.jsonb       :business_settings, default: {}
      t.jsonb       :tax_settings, default: {}
      t.string      :currency, null: false, limit: 3

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :clients, :uuid, unique: true
  end
end
