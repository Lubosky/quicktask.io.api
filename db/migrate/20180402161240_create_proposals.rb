class CreateProposals < ActiveRecord::Migration[5.2]
  def change
    create_table :proposals, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.references  :client_request, foreign_key: true, index: true, null: false
      t.references  :quote, foreign_key: true, index: true, null: false

      t.timestamps
    end
  end
end
