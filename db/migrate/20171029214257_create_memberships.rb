class CreateMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :memberships, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :workspace, null: false
      t.belongs_to  :plan, null: false
      t.belongs_to  :owner, references: :user, null: false
      t.string      :stripe_subscription_id, index: true

      t.integer     :status
      t.integer     :quantity

      t.boolean     :free_license, default: false
      t.datetime    :trial_period_end_date
      t.integer     :trial_period_extension_days, default: 0, null: false

      t.date        :scheduled_for_deactivation_on
      t.date        :deactivated_on

      t.date        :scheduled_for_reactivation_on
      t.date        :reactivated_on

      t.decimal     :next_payment_amount, default: 0.0, null: false
      t.date        :next_payment_on

      t.jsonb       :coupon_codes, default: []
      t.jsonb       :metadata, default: {}

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :memberships, :uuid, unique: true
  end
end
