class CreateTeamMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :team_members, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false

      t.string      :title
      t.string      :first_name, default: '', null: false
      t.string      :last_name, default: '', null: false
      t.string      :email, null: false

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :team_members, :uuid, unique: true
  end
end
