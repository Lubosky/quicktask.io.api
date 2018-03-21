class CreateTaskTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :task_types, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false, index: false

      t.integer     :classification, null: false
      t.string      :name, null: false

      t.boolean     :billable, default: false, null: false
      t.boolean     :internal, default: false, null: false
      t.boolean     :preferred, default: false, null: false
      t.boolean     :net_rate_scheme, default: false, null: false

      t.decimal     :hourly_cost, default: 0.0, null: false

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :task_types, :uuid, unique: true
  end
end
