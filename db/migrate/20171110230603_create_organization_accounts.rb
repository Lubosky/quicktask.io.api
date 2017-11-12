class CreateOrganizationAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :organization_accounts, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.references  :account, polymorphic: true, null: false
      t.belongs_to  :role, null: false
      t.belongs_to  :workspace, null: false
      t.belongs_to  :user, null: false

      t.integer     :status
      t.jsonb       :workspace_settings, default: {}
      t.jsonb       :metadata, default: {}

      t.timestamps
      t.datetime    :deleted_at
      t.datetime    :deactivated_at
    end

    add_index :organization_accounts, :uuid, unique: true
  end
end
