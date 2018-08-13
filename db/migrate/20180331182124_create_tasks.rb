class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :tasklist, null: false
      t.belongs_to  :project, null: false
      t.belongs_to  :owner, references: :team_member, index: false
      t.belongs_to  :workspace, null: false

      t.belongs_to  :source_language, references: :language, index: false
      t.belongs_to  :target_language, references: :language, index: false
      t.belongs_to  :task_type, index: false
      t.belongs_to  :unit, index: false

      t.string      :title, null: false
      t.string      :description

      t.integer     :color
      t.integer     :status

      t.datetime    :start_date
      t.datetime    :due_date
      t.datetime    :completed_date

      t.integer     :recurring_type, null: false
      t.datetime    :recurring_due_date

      t.jsonb       :task_data, default: {}
      t.jsonb       :metadata, default: {}

      t.float       :unit_count, default: 0.0, null: false
      t.float       :completed_unit_count, default: 0.0, null: false
      t.integer     :attachment_count, default: 0, null: false
      t.integer     :comment_count, default: 0, null: false

      t.integer     :position

      t.timestamps
      t.datetime    :deleted_at
    end
  end
end
