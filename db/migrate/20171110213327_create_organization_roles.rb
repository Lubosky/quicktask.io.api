class CreateOrganizationRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :organization_roles, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false

      t.string      :permission_level, null: false
      t.string      :name, null: false, limit: 45
      t.boolean     :default, default: false, null: false
      t.jsonb       :permissions, default: [], null: false

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :organization_roles, :uuid, unique: true
    add_index :organization_roles, :permissions, using: :gin
  end
end
