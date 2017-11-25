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

ActiveRecord::Schema.define(version: 20171121215127) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "charges", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.string "stripe_charge_id"
    t.string "stripe_invoice_id"
    t.decimal "amount", default: "0.0", null: false
    t.string "description"
    t.date "paid_through_date"
    t.jsonb "source", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id"], name: "index_charges_on_workspace_id"
  end

  create_table "client_contacts", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "client_id", null: false
    t.bigint "workspace_id", null: false
    t.string "title"
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "email"
    t.string "phone_office"
    t.string "phone_mobile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_client_contacts_on_client_id"
    t.index ["uuid"], name: "index_client_contacts_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_client_contacts_on_workspace_id"
  end

  create_table "clients", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.boolean "internal", default: false, null: false
    t.string "name", null: false
    t.string "email"
    t.string "phone"
    t.jsonb "business_settings", default: {}
    t.jsonb "tax_settings", default: {}
    t.string "currency", limit: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["uuid"], name: "index_clients_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_clients_on_workspace_id"
  end

  create_table "contractors", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "business_name"
    t.string "email"
    t.string "phone"
    t.jsonb "business_settings", default: {}
    t.jsonb "tax_settings", default: {}
    t.string "currency", limit: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["uuid"], name: "index_contractors_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_contractors_on_workspace_id"
  end

  create_table "memberships", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.bigint "plan_id", null: false
    t.bigint "owner_id", null: false
    t.string "stripe_subscription_id"
    t.integer "status"
    t.integer "quantity"
    t.boolean "free_license", default: false
    t.datetime "trial_period_end_date"
    t.integer "trial_period_extension_days", default: 0, null: false
    t.date "scheduled_for_deactivation_on"
    t.date "deactivated_on"
    t.date "scheduled_for_reactivation_on"
    t.date "reactivated_on"
    t.decimal "next_payment_amount", default: "0.0", null: false
    t.date "next_payment_on"
    t.jsonb "coupon_codes", default: []
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["owner_id"], name: "index_memberships_on_owner_id"
    t.index ["plan_id"], name: "index_memberships_on_plan_id"
    t.index ["stripe_subscription_id"], name: "index_memberships_on_stripe_subscription_id"
    t.index ["uuid"], name: "index_memberships_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_memberships_on_workspace_id"
  end

  create_table "organization_currencies", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.string "code", null: false
    t.decimal "exchange_rate", precision: 22, scale: 11, default: "1.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["code", "workspace_id"], name: "index_organization_currencies_on_code_and_workspace_id"
    t.index ["uuid"], name: "index_organization_currencies_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_organization_currencies_on_workspace_id"
  end

  create_table "organization_accounts", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.string "account_type", null: false
    t.bigint "account_id", null: false
    t.bigint "role_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "user_id", null: false
    t.integer "status"
    t.jsonb "workspace_settings", default: {}
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "deactivated_at"
    t.index ["account_type", "account_id"], name: "index_organization_accounts_on_account_type_and_account_id"
    t.index ["role_id"], name: "index_organization_accounts_on_role_id"
    t.index ["user_id"], name: "index_organization_accounts_on_user_id"
    t.index ["uuid"], name: "index_organization_accounts_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_organization_accounts_on_workspace_id"
  end

  create_table "organization_roles", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.string "permission_level", null: false
    t.string "name", limit: 45, null: false
    t.boolean "default", default: false, null: false
    t.jsonb "permissions", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["permissions"], name: "index_organization_roles_on_permissions", using: :gin
    t.index ["uuid"], name: "index_organization_roles_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_organization_roles_on_workspace_id"
  end

  create_table "organizations", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "owner_id", null: false
    t.string "stripe_customer_id"
    t.string "slug", null: false
    t.string "name", null: false
    t.string "business_name"
    t.jsonb "business_settings", default: {}
    t.jsonb "tax_settings", default: {}
    t.jsonb "workspace_settings", default: {}
    t.string "currency", limit: 3, null: false
    t.jsonb "logo_data"
    t.integer "status"
    t.integer "team_member_count", default: 0, null: false
    t.integer "team_member_limit", default: 0, null: false
    t.jsonb "stats", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["owner_id"], name: "index_organizations_on_owner_id"
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
    t.index ["stripe_customer_id"], name: "index_organizations_on_stripe_customer_id"
    t.index ["uuid"], name: "index_organizations_on_uuid", unique: true
  end

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

  create_table "project_groups", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "client_id", null: false
    t.bigint "workspace_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_project_groups_on_client_id"
    t.index ["uuid"], name: "index_project_groups_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_project_groups_on_workspace_id"
  end

  create_table "projects", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "client_id"
    t.bigint "owner_id"
    t.bigint "workspace_id", null: false
    t.bigint "project_group_id"
    t.string "project_type", null: false
    t.integer "workflow_type"
    t.string "name", null: false
    t.string "description"
    t.string "identifier"
    t.integer "status"
    t.datetime "start_date"
    t.datetime "due_date"
    t.datetime "completed_date"
    t.boolean "billed", default: false, null: false
    t.jsonb "settings", default: {}
    t.jsonb "notification_settings", default: {}
    t.jsonb "metadata", default: {}
    t.integer "task_count", default: 0
    t.integer "completed_task_count", default: 0
    t.float "completion_ratio", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_projects_on_client_id"
    t.index ["owner_id"], name: "index_projects_on_owner_id"
    t.index ["project_group_id"], name: "index_projects_on_project_group_id"
    t.index ["project_type", "workspace_id"], name: "index_projects_on_project_type_and_workspace_id"
    t.index ["uuid"], name: "index_projects_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_projects_on_workspace_id"
  end

  create_table "team_members", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.string "title"
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["uuid"], name: "index_team_members_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_team_members_on_workspace_id"
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
