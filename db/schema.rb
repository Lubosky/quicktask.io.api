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

ActiveRecord::Schema.define(version: 2018_10_11_211036) do

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

  create_table "client_requests", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "client_id", null: false
    t.bigint "requester_id", null: false
    t.bigint "workspace_id", null: false
    t.string "request_type", null: false
    t.string "subject", default: "", null: false
    t.string "identifier"
    t.bigint "service_id", null: false
    t.bigint "source_language_id"
    t.jsonb "target_language_ids", default: [], array: true
    t.bigint "unit_id"
    t.float "unit_count", default: 0.0, null: false
    t.decimal "estimated_cost", precision: 19, scale: 4, default: "0.0", null: false
    t.integer "status"
    t.datetime "start_date"
    t.datetime "due_date"
    t.text "notes"
    t.jsonb "request_data", default: {}
    t.jsonb "currency_data", default: {}
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_client_requests_on_client_id"
    t.index ["requester_id"], name: "index_client_requests_on_requester_id"
    t.index ["uuid"], name: "index_client_requests_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_client_requests_on_workspace_id"
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

  create_table "hand_offs", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.string "assignee_type", null: false
    t.bigint "assignee_id", null: false
    t.bigint "assigner_id", null: false
    t.bigint "task_id", null: false
    t.bigint "workspace_id", null: false
    t.datetime "valid_through"
    t.decimal "rate_applied", precision: 19, scale: 4, default: "0.0", null: false
    t.datetime "accepted_at"
    t.datetime "rejected_at"
    t.datetime "expired_at"
    t.datetime "cancelled_at"
    t.bigint "canceller_id"
    t.integer "view_count", default: 0, null: false
    t.datetime "last_viewed_at"
    t.integer "email_count", default: 0, null: false
    t.datetime "last_emailed_at"
    t.boolean "assignment", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["assignee_type", "assignee_id"], name: "index_hand_offs_on_assignee_type_and_assignee_id"
    t.index ["task_id"], name: "index_hand_offs_on_task_id"
    t.index ["workspace_id"], name: "index_hand_offs_on_workspace_id"
  end

  create_table "languages", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.boolean "preferred", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["code", "workspace_id"], name: "index_languages_on_code_and_workspace_id"
    t.index ["uuid"], name: "index_languages_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_languages_on_workspace_id"
  end

  create_table "line_items", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.string "bookkeepable_type", null: false
    t.bigint "bookkeepable_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "source_language_id"
    t.bigint "target_language_id"
    t.bigint "task_type_id", null: false
    t.bigint "unit_id", null: false
    t.string "description"
    t.float "quantity", null: false
    t.decimal "unit_price", precision: 19, scale: 4, null: false
    t.decimal "discount", precision: 6, scale: 5, default: "0.0", null: false
    t.decimal "surcharge", precision: 6, scale: 5, default: "0.0", null: false
    t.decimal "subtotal", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "total", precision: 19, scale: 4, default: "0.0", null: false
    t.jsonb "line_item_data", default: {}
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["bookkeepable_type", "bookkeepable_id"], name: "index_line_items_on_bookkeepable_type_and_bookkeepable_id"
    t.index ["workspace_id"], name: "index_line_items_on_workspace_id"
  end

  create_table "locations", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.string "addressable_type", null: false
    t.bigint "addressable_id", null: false
    t.bigint "workspace_id", null: false
    t.string "street_name"
    t.string "street_number"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country"
    t.string "address"
    t.string "formatted_address"
    t.point "coordinates"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["addressable_type", "addressable_id"], name: "index_locations_on_addressable_type_and_addressable_id"
    t.index ["uuid"], name: "index_locations_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_locations_on_workspace_id"
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

  create_table "project_estimates", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "quote_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_estimates_on_project_id"
    t.index ["quote_id"], name: "index_project_estimates_on_quote_id"
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

  create_table "proposals", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.bigint "client_request_id", null: false
    t.bigint "quote_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_request_id"], name: "index_proposals_on_client_request_id"
    t.index ["quote_id"], name: "index_proposals_on_quote_id"
  end

  create_table "purchase_orders", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.bigint "issuer_id", null: false
    t.bigint "updater_id"
    t.bigint "hand_off_id", null: false
    t.bigint "workspace_id", null: false
    t.string "subject", null: false
    t.string "identifier"
    t.string "purchase_order_number"
    t.jsonb "purchase_order_data"
    t.datetime "issue_date"
    t.boolean "billed", default: false, null: false
    t.jsonb "currency_data", default: {}
    t.jsonb "metadata", default: {}
    t.decimal "discount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "surcharge", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "subtotal", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "total", precision: 19, scale: 4, default: "0.0", null: false
    t.text "notes"
    t.text "terms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["hand_off_id"], name: "index_purchase_orders_on_hand_off_id"
    t.index ["owner_type", "owner_id"], name: "index_purchase_orders_on_owner_type_and_owner_id"
    t.index ["uuid"], name: "index_purchase_orders_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_purchase_orders_on_workspace_id"
  end

  create_table "quotes", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "client_id"
    t.bigint "owner_id"
    t.bigint "workspace_id", null: false
    t.string "quote_type", null: false
    t.string "subject", null: false
    t.string "identifier"
    t.string "purchase_order_number"
    t.jsonb "purchase_order_data"
    t.integer "status"
    t.datetime "issue_date"
    t.datetime "expiry_date"
    t.datetime "start_date"
    t.datetime "due_date"
    t.boolean "billed", default: false, null: false
    t.jsonb "quote_data", default: {}
    t.jsonb "currency_data", default: {}
    t.jsonb "settings", default: {}
    t.jsonb "metadata", default: {}
    t.decimal "discount", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "surcharge", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "subtotal", precision: 19, scale: 4, default: "0.0", null: false
    t.decimal "total", precision: 19, scale: 4, default: "0.0", null: false
    t.text "notes"
    t.text "terms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_quotes_on_client_id"
    t.index ["quote_type", "workspace_id"], name: "index_quotes_on_quote_type_and_workspace_id"
    t.index ["uuid"], name: "index_quotes_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_quotes_on_workspace_id"
  end

  create_table "rates", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "task_type_id", null: false
    t.bigint "source_language_id"
    t.bigint "target_language_id"
    t.bigint "unit_id", null: false
    t.bigint "client_id"
    t.bigint "owner_id", null: false
    t.bigint "workspace_id", null: false
    t.string "rate_type", null: false
    t.integer "classification", null: false
    t.decimal "price", precision: 19, scale: 4, default: "0.0", null: false
    t.string "currency", limit: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["owner_id"], name: "index_rates_on_owner_id"
    t.index ["task_type_id"], name: "index_rates_on_task_type_id"
    t.index ["uuid"], name: "index_rates_on_uuid", unique: true
    t.index ["workspace_id", "rate_type"], name: "index_rates_on_workspace_id_and_rate_type"
  end

  create_table "service_tasks", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.bigint "service_id"
    t.bigint "task_type_id"
    t.integer "position"
    t.index ["service_id"], name: "index_service_tasks_on_service_id"
    t.index ["task_type_id"], name: "index_service_tasks_on_task_type_id"
  end

  create_table "services", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.integer "classification", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["uuid"], name: "index_services_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_services_on_workspace_id"
  end

  create_table "specialization_relations", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "specializable_type", null: false
    t.bigint "specializable_id", null: false
    t.bigint "specialization_id", null: false
    t.index ["specializable_type", "specializable_id"], name: "index_specialization_relations_on_specializable"
    t.index ["specialization_id"], name: "index_specialization_relations_on_specialization_id"
  end

  create_table "specializations", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.string "name", null: false
    t.boolean "default", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["uuid"], name: "index_specializations_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_specializations_on_workspace_id"
  end

  create_table "taggings", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.bigint "tag_id", null: false
    t.string "taggable_type", null: false
    t.bigint "taggable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id", "tag_id"], name: "index_taggings_on_taggable_type_and_taggable_id_and_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["workspace_id", "taggable_type", "taggable_id", "tag_id"], name: "index_unique_taggings", unique: true
    t.index ["workspace_id"], name: "index_taggings_on_workspace_id"
  end

  create_table "tags", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.string "name", null: false
    t.integer "color"
    t.integer "tagging_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["name"], name: "index_tags_on_name"
    t.index ["workspace_id", "name", "deleted_at"], name: "index_tags_on_workspace_id_and_name_and_deleted_at", unique: true
    t.index ["workspace_id"], name: "index_tags_on_workspace_id"
  end

  create_table "task_dependencies", id: false, force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "dependent_on_task_id", null: false
    t.index ["dependent_on_task_id"], name: "index_task_dependencies_on_dependent_on_task_id"
    t.index ["task_id", "dependent_on_task_id"], name: "index_task_dependencies_on_task_id_and_dependent_on_task_id"
    t.index ["task_id"], name: "index_task_dependencies_on_task_id"
  end

  create_table "task_types", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.integer "classification", null: false
    t.string "name", null: false
    t.boolean "billable", default: false, null: false
    t.boolean "internal", default: false, null: false
    t.boolean "preferred", default: false, null: false
    t.boolean "net_rate_scheme", default: false, null: false
    t.decimal "hourly_cost", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["uuid"], name: "index_task_types_on_uuid", unique: true
  end

  create_table "tasklists", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "project_id", null: false
    t.bigint "owner_id"
    t.bigint "workspace_id", null: false
    t.string "title", null: false
    t.integer "task_count", default: 0, null: false
    t.integer "completed_task_count", default: 0, null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["project_id"], name: "index_tasklists_on_project_id"
    t.index ["workspace_id"], name: "index_tasklists_on_workspace_id"
  end

  create_table "tasks", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "tasklist_id", null: false
    t.bigint "project_id", null: false
    t.bigint "owner_id"
    t.bigint "workspace_id", null: false
    t.bigint "source_language_id"
    t.bigint "target_language_id"
    t.bigint "task_type_id"
    t.bigint "unit_id"
    t.string "title", null: false
    t.string "description"
    t.integer "color"
    t.integer "status"
    t.datetime "start_date"
    t.datetime "due_date"
    t.datetime "completed_date"
    t.integer "recurring_type", null: false
    t.datetime "recurring_due_date"
    t.jsonb "task_data", default: {}
    t.jsonb "metadata", default: {}
    t.float "unit_count", default: 0.0, null: false
    t.float "completed_unit_count", default: 0.0, null: false
    t.integer "attachment_count", default: 0, null: false
    t.integer "comment_count", default: 0, null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["tasklist_id"], name: "index_tasks_on_tasklist_id"
    t.index ["workspace_id"], name: "index_tasks_on_workspace_id"
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

  create_table "todos", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "task_id", null: false
    t.bigint "workspace_id", null: false
    t.bigint "assignee_id"
    t.string "title", null: false
    t.datetime "due_date"
    t.datetime "completed_date"
    t.boolean "completed", default: false, null: false
    t.jsonb "todo_data", default: {}
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["assignee_id"], name: "index_todos_on_assignee_id"
    t.index ["task_id"], name: "index_todos_on_task_id"
    t.index ["workspace_id"], name: "index_todos_on_workspace_id"
  end

  create_table "tokens", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.datetime "issued_at"
    t.datetime "expiry_date"
    t.index ["subject_id"], name: "index_tokens_on_subject_id"
  end

  create_table "units", id: :bigint, default: -> { "generate_id()" }, force: :cascade do |t|
    t.string "uuid", limit: 24, null: false
    t.bigint "workspace_id", null: false
    t.integer "unit_type"
    t.string "name", null: false
    t.boolean "deletable", default: true, null: false
    t.boolean "internal", default: false, null: false
    t.boolean "preferred", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["uuid"], name: "index_units_on_uuid", unique: true
    t.index ["workspace_id"], name: "index_units_on_workspace_id"
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

  add_foreign_key "project_estimates", "projects"
  add_foreign_key "project_estimates", "quotes"
  add_foreign_key "proposals", "client_requests"
  add_foreign_key "proposals", "quotes"
  add_foreign_key "service_tasks", "services"
  add_foreign_key "service_tasks", "task_types"
  add_foreign_key "specialization_relations", "specializations"
  add_foreign_key "task_dependencies", "tasks"
  add_foreign_key "task_dependencies", "tasks", column: "dependent_on_task_id"
end
