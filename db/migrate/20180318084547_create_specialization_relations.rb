class CreateSpecializationRelations < ActiveRecord::Migration[5.1]
  def change
    create_table :specialization_relations, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.references  :specializable, polymorphic: true, null: false, index: { name: 'index_specialization_relations_on_specializable' }
      t.references  :specialization, null: false, foreign_key: true
    end
  end
end
