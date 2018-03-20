class CreateClientRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :client_requests, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :client, null: false
      t.belongs_to  :requester, references: :client_contact, null: false
      t.belongs_to  :workspace, null: false

      t.string      :request_type, null: false

      t.string      :subject, default: '', null: false
      t.string      :identifier

      t.references  :service, null: false, index: false
      t.references  :source_language, index: false
      t.jsonb       :target_language_ids, array: true, default: []

      t.references  :unit, index: false
      t.float       :unit_count, default: 0.0, null: false

      t.decimal     :estimated_cost, default: 0.0, null: false, precision: 19, scale: 4

      t.integer     :status
      t.datetime    :start_date
      t.datetime    :due_date

      t.text        :notes

      t.jsonb       :request_data, default: {}
      t.jsonb       :currency_data, default: {}
      t.jsonb       :metadata, default: {}

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :client_requests, :uuid, unique: true
  end
end
