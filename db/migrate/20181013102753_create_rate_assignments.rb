class CreateRateAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :rate_assignments, id: false do |t|
      t.belongs_to :contractor, foreign_key: true, null: false
      t.belongs_to :rate, foreign_key: true, null: false
    end

    add_index :rate_assignments, [:rate_id, :contractor_id]
  end
end
