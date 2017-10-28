# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171024162318) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "plans", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.string "stripe_plan_id", null: false
    t.string "name", null: false
    t.decimal "price", precision: 6, scale: 2, null: false
    t.int4range "range", null: false
    t.integer "billing_interval", null: false
    t.integer "trial_period_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["uuid"], name: "index_plans_on_uuid", unique: true
  end

  create_table "tokens", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.datetime "issued_at"
    t.datetime "expiry_date"
    t.index ["subject_id"], name: "index_tokens_on_subject_id"
  end

  create_table "users", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.string "email", null: false
    t.string "google_uid"
    t.string "password_digest"
    t.boolean "password_automatically_set", default: false, null: false
    t.boolean "email_confirmed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "deactivated_at"
    t.datetime "last_login_at"
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.jsonb "avatar_data"
    t.string "locale", default: "en", null: false
    t.string "time_zone", default: "UTC", null: false
    t.jsonb "settings", default: {}, null: false
    t.index ["email", "deleted_at"], name: "index_users_on_email_and_deleted_at", unique: true
    t.index ["google_uid", "deleted_at"], name: "index_users_on_google_uid_and_deleted_at", unique: true
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end

end
