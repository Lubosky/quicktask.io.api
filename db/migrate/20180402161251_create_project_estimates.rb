class CreateProjectEstimates < ActiveRecord::Migration[5.2]
  def change
    create_table :project_estimates, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.references  :project, foreign_key: true, index: true, null: false
      t.references  :quote, foreign_key: true, index: true, null: false

      t.timestamps
    end
  end
end
