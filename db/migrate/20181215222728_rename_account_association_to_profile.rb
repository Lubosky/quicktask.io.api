class RenameAccountAssociationToProfile < ActiveRecord::Migration[5.2]
  def change
    rename_column :organization_accounts, :account_type, :profile_type
    rename_column :organization_accounts, :account_id, :profile_id
  end
end
