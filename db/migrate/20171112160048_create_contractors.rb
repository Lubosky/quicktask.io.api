class CreateContractors < ActiveRecord::Migration[5.1]
  def change
    create_table :contractors, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false

      t.string      :first_name, default: '', null: false
      t.string      :last_name, default: '', null: false
      t.string      :business_name

      t.string      :email
      t.string      :phone

      t.jsonb       :business_settings, default: {}
      t.jsonb       :tax_settings, default: {}
      t.string      :currency, null: false, limit: 3

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :contractors, :uuid, unique: true
  end
end
