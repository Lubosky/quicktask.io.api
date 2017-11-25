class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :client
      t.belongs_to  :owner, references: :workspace_user
      t.belongs_to  :workspace, null: false
      t.belongs_to  :project_group

      t.string      :project_type, null: false
      t.integer     :workflow_type

      t.string      :name, null: false
      t.string      :description
      t.string      :identifier

      t.integer     :status
      t.datetime    :start_date
      t.datetime    :due_date
      t.datetime    :completed_date

      t.boolean     :billed, default: false, null: false

      t.jsonb       :settings, default: {}
      t.jsonb       :notification_settings, default: {}
      t.jsonb       :metadata, default: {}

      t.integer     :task_count, default: 0
      t.integer     :completed_task_count, default: 0
      t.float       :completion_ratio, default: 0.0

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :projects, :uuid, unique: true
    add_index :projects, [:project_type, :workspace_id]
  end
end
