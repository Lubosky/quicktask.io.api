class CreateServiceTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :service_tasks, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.references  :service, index: true, foreign_key: true
      t.references  :task_type, index: true, foreign_key: true
      t.integer     :position
    end
  end
end
