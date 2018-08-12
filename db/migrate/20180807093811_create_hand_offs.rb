class CreateHandOffs < ActiveRecord::Migration[5.2]
  def change
    create_table :hand_offs, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.references  :assignee, polymorphic: true, null: false
      t.belongs_to  :assigner, references: :team_member, index: false, null: false
      t.belongs_to  :task, null: false
      t.belongs_to  :workspace, null: false

      t.datetime    :valid_through
      t.decimal     :rate_applied, default: 0.0, null: false, precision: 19, scale: 4

      t.datetime    :accepted_at
      t.datetime    :rejected_at
      t.datetime    :expired_at
      t.datetime    :cancelled_at
      t.belongs_to  :canceller, references: :team_member, index: false

      t.integer     :view_count, default: 0, null: false
      t.datetime    :last_viewed_at
      t.integer     :email_count, default: 0, null: false
      t.datetime    :last_emailed_at

      t.boolean     :assignment, default: false, null: false

      t.timestamps
      t.datetime    :deleted_at
    end
  end
end

