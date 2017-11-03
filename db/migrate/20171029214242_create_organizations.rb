class CreateOrganizations < ActiveRecord::Migration[5.1]
  def change
    create_table :organizations, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :owner, references: :user, null: false
      t.string      :stripe_customer_id, index: true

      t.string      :slug, null: false
      t.string      :name, null: false
      t.string      :business_name
      t.jsonb       :business_settings, default: {}
      t.jsonb       :tax_settings, default: {}
      t.jsonb       :workspace_settings, default: {}
      t.string      :currency, null: false, limit: 3
      t.jsonb       :logo_data

      t.integer     :status
      t.integer     :team_member_count, default: 0, null: false
      t.integer     :team_member_limit, default: 0, null: false
      t.jsonb       :stats, default: {}

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :organizations, :uuid, unique: true
    add_index :organizations, :slug, unique: true
  end
end
