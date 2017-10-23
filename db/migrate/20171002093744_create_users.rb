class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.string      :email, null: false
      t.string      :google_uid
      t.string      :password_digest
      t.boolean     :password_automatically_set, default: false, null: false

      t.boolean     :email_confirmed, default: false, null: false

      t.timestamps
      t.datetime    :deleted_at
      t.datetime    :deactivated_at
      t.datetime    :last_login_at

      t.string      :first_name, default: '', null: false
      t.string      :last_name, default: '', null: false

      t.jsonb       :avatar_data
      t.string      :locale, default: 'en', null: false
      t.string      :time_zone, default: 'UTC', null: false
      t.jsonb       :settings, default: {}, null: false
    end

    add_index :users, :uuid, unique: true
    add_index :users, [:email, :deleted_at], unique: true
    add_index :users, [:google_uid, :deleted_at], unique: true
  end
end
