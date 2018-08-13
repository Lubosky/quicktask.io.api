class CreateTasklists < ActiveRecord::Migration[5.2]
  def change
    create_table :tasklists, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :project, null: false
      t.belongs_to  :owner, references: :team_member, index: false
      t.belongs_to  :workspace, null: false

      t.string      :title, null: false

      t.integer     :task_count, default: 0, null: false
      t.integer     :completed_task_count, default: 0, null: false

      t.integer     :position

      t.timestamps
      t.datetime    :deleted_at
    end
  end
end
