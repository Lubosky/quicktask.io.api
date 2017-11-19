class CreateClientContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :client_contacts, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :client, null: false
      t.belongs_to  :workspace, null: false

      t.string      :title
      t.string      :first_name, default: '', null: false
      t.string      :last_name, default: '', null: false
      t.string      :email
      t.string      :phone_office
      t.string      :phone_mobile

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :client_contacts, :uuid, unique: true
  end
end
