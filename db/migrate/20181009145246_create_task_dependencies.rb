class CreateTaskDependencies < ActiveRecord::Migration[5.2]
  def change
    create_table :task_dependencies, id: false do |t|
      t.belongs_to :task, foreign_key: true, null: false
      t.belongs_to :dependent_on_task, references: :task, null: false
    end

    add_foreign_key :task_dependencies, :tasks, column: :dependent_on_task_id
    add_index :task_dependencies, [:task_id, :dependent_on_task_id]
  end
end
