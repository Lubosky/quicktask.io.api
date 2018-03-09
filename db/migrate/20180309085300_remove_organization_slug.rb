class RemoveOrganizationSlug < ActiveRecord::Migration[5.1]
  def up
    remove_column :organizations, :slug
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
