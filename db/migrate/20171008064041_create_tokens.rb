class CreateTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :tokens, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.belongs_to :subject, references: :user, null: false
      t.datetime :issued_at
      t.datetime :expiry_date
    end
  end
end
