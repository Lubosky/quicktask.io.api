class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations, id: :bigint, default: -> { 'generate_id()' } do |t|
      t.string      :uuid, null: false, limit: 24
      t.belongs_to  :addressable, polymorphic: true, null: false
      t.belongs_to  :workspace, null: false

      t.string      :street_name
      t.string      :street_number
      t.string      :city
      t.string      :state
      t.string      :postal_code
      t.string      :country
      t.string      :address
      t.string      :formatted_address
      t.point       :coordinates
      t.float       :latitude
      t.float       :longitude

      t.timestamps
      t.datetime    :deleted_at
    end

    add_index :locations, :uuid, unique: true
  end
end
