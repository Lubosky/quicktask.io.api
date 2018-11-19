class CreateTodos < ActiveRecord::Migration[5.2]
  def change
    create_table :todos, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :task, null: false
      t.belongs_to  :workspace, null: false
      t.belongs_to  :assignee, references: :workspace_account

      t.string      :title, null: false

      t.datetime    :due_date
      t.datetime    :completed_date
      t.boolean     :completed, default: false, null: false

      t.jsonb       :todo_data, default: {}
      t.integer     :position

      t.timestamps
      t.datetime    :deleted_at
    end
  end
end
