class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string    :uuid, null: false, limit: 24
      t.string    :stripe_plan_id, null: false
      t.string    :name, null: false
      t.decimal   :price, null: false, precision: 6, scale: 2
      t.int4range :range, null: false
      t.integer   :billing_interval, null: false
      t.integer   :trial_period_days

      t.timestamps
      t.datetime  :deleted_at
    end

    add_index :plans, :uuid, unique: true
  end
end
