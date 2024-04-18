# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_08_19_043518) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "account_deletion_follow_ups", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "status", default: 0
    t.string "stripe_customer_id"
    t.string "stripe_account_id"
    t.boolean "required_for_individual", default: false
    t.boolean "required_for_expert", default: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
  end

  create_table "alerts", force: :cascade do |t|
    t.string "alertable_type", null: false
    t.uuid "alertable_id", null: false
    t.string "message"
    t.integer "alert_type"
    t.string "note"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_policies", force: :cascade do |t|
    t.string "title", null: false
    t.string "description", default: [], array: true
    t.boolean "expert"
    t.boolean "individual"
    t.boolean "global", default: false
    t.boolean "has_changed", default: true
    t.string "version"
    t.string "status", default: "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "app_versions", force: :cascade do |t|
    t.string "platform"
    t.string "version"
    t.boolean "force_update"
    t.boolean "supported"
    t.boolean "is_latest"
    t.datetime "release_date"
    t.datetime "support_ends_on"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "attachments", force: :cascade do |t|
    t.uuid "quick_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_key", null: false
    t.string "file_name", null: false
    t.string "file_type", null: false
    t.integer "file_size", null: false
    t.boolean "in_bucket", default: false, null: false
    t.uuid "message_id"
    t.index ["message_id"], name: "index_attachments_on_message_id"
  end

  create_table "availabilities", force: :cascade do |t|
    t.uuid "expert_id", null: false
    t.boolean "monday", default: false, null: false
    t.boolean "tuesday", default: false, null: false
    t.boolean "wednesday", default: false, null: false
    t.boolean "thursday", default: false, null: false
    t.boolean "friday", default: false, null: false
    t.boolean "saturday", default: false, null: false
    t.boolean "sunday", default: false, null: false
    t.string "time_start_weekday"
    t.string "time_end_weekday"
    t.string "time_start_weekend"
    t.string "time_end_weekend"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "interactions_count", default: 0, null: false
    t.string "status", default: "Active"
  end

  create_table "categories_experts", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.uuid "expert_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "category_interactions", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "interaction_type", null: false
    t.bigint "interaction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.uuid "expert_call_id"
    t.string "status", default: "active"
    t.string "sid"
    t.string "name"
    t.jsonb "room_data", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["expert_call_id"], name: "index_chat_rooms_on_expert_call_id"
  end

  create_table "complaints", force: :cascade do |t|
    t.uuid "individual_id", null: false
    t.uuid "expert_id", null: false
    t.bigint "expert_interaction_id"
    t.text "content"
    t.string "status", default: "requires_verification", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contact_form_submissions", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "title"
    t.text "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "devices", force: :cascade do |t|
    t.string "token"
    t.string "os"
    t.bigint "user_id", null: false
    t.string "version"
    t.string "device_name"
    t.string "language"
    t.string "timezone"
    t.string "time_format"
    t.string "os_version"
    t.string "app_build"
    t.string "environment"
    t.string "ios_push_notifications"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expert_calls", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "expert_id", null: false
    t.uuid "individual_id", null: false
    t.integer "category_id"
    t.string "call_type", null: false
    t.string "title", null: false
    t.string "description", null: false
    t.datetime "scheduled_time_start", null: false
    t.datetime "scheduled_time_end", null: false
    t.integer "rate", null: false
    t.string "call_status", default: "requires_confirmation", null: false
    t.datetime "time_start"
    t.datetime "time_end"
    t.string "room_id"
    t.integer "guests_count", default: 0, null: false
    t.string "payment_id"
    t.string "payment_status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "call_time", default: 0, null: false
    t.string "stripe_payment_method_id"
    t.integer "scheduled_call_duration", default: 20, null: false
    t.string "cancelled_by_type"
    t.uuid "cancelled_by_id"
    t.string "cancellation_reason", limit: 1000
    t.datetime "cancelled_at"
    t.string "room_status", default: "creation_pending"
    t.string "room_creation_failure_reason"
    t.index ["cancelled_by_type", "cancelled_by_id"], name: "index_expert_calls_on_cancelled_by"
    t.index ["category_id"], name: "index_expert_calls_on_category_id"
    t.index ["expert_id"], name: "index_expert_calls_on_expert_id"
    t.index ["individual_id"], name: "index_expert_calls_on_individual_id"
    t.index ["room_status"], name: "index_expert_calls_on_room_status"
  end

  create_table "expert_interactions", force: :cascade do |t|
    t.uuid "expert_id", null: false
    t.string "interaction_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "interaction_id", null: false
    t.boolean "was_helpful"
    t.float "rating"
    t.text "feedback"
    t.datetime "reviewed_at"
    t.index ["expert_id"], name: "index_expert_interactions_on_expert_id"
    t.index ["interaction_type", "interaction_id"], name: "index_expert_interactions_on_interaction"
  end

  create_table "experts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "stripe_account_id"
    t.boolean "stripe_account_set", default: false
    t.boolean "can_receive_stripe_transfers", default: false
    t.integer "status", default: 0, null: false
    t.text "biography"
    t.string "website_url"
    t.string "linkedin_url"
    t.integer "quick_question_rate"
    t.integer "one_to_one_video_call_rate"
    t.integer "one_to_five_video_call_rate"
    t.integer "extra_user_rate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "featured", default: false
    t.integer "interactions_count", default: 0, null: false
    t.integer "total_earnings", default: 0, null: false
    t.integer "pending_events", default: 0, null: false
    t.string "stripe_bank_account_id"
    t.string "bank_account_last4"
    t.string "twitter_url"
    t.string "instagram_url"
    t.boolean "ready_for_deletion", default: false
    t.integer "quick_question_text_rate", default: 50
    t.integer "quick_question_video_rate", default: 70
    t.integer "video_call_rate", default: 15
    t.float "rating", default: 0.0
    t.integer "reviews_count"
    t.string "slug"
    t.integer "payout_percentage", default: 80
    t.index ["slug"], name: "index_experts_on_slug", unique: true
    t.index ["stripe_account_id", "stripe_account_set"], name: "index_experts_stripe_account_id_and_set"
    t.index ["stripe_account_set", "can_receive_stripe_transfers"], name: "index_experts_stripe_account_set_and_can_get_transfers"
    t.index ["user_id"], name: "index_experts_on_user_id"
  end

  create_table "guest_in_calls", force: :cascade do |t|
    t.uuid "individual_id", null: false
    t.uuid "expert_call_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "confirmed"
  end

  create_table "individuals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "stripe_customer_id"
    t.boolean "has_stripe_payment_method", default: false
    t.string "username"
    t.boolean "ready_for_deletion", default: false
    t.index ["user_id"], name: "index_individuals_on_user_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "message_reads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "reader_type"
    t.uuid "reader_id"
    t.uuid "message_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["message_id"], name: "index_message_reads_on_message_id"
    t.index ["reader_type", "reader_id"], name: "index_message_reads_on_reader"
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "text"
    t.string "sender_type", null: false
    t.uuid "sender_id", null: false
    t.string "content_type"
    t.bigint "attachment_id"
    t.string "status", default: "sent"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "private_chat_id", null: false
    t.string "answer_type", default: "text"
    t.index ["attachment_id"], name: "index_messages_on_attachment_id"
    t.index ["private_chat_id"], name: "index_messages_on_private_chat_id"
    t.index ["sender_type", "sender_id"], name: "index_messages_on_sender"
  end

  create_table "participant_events", force: :cascade do |t|
    t.uuid "expert_call_id", null: false
    t.string "participant_id", null: false
    t.string "event_name", null: false
    t.integer "duration"
    t.datetime "event_datetime", null: false
    t.boolean "initial", default: false, null: false
    t.boolean "expert", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_updates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "payment_id", null: false
    t.json "changes"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_id"], name: "index_payment_updates_on_payment_id"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount"
    t.string "currency"
    t.string "status"
    t.string "payable_type", null: false
    t.uuid "payable_id", null: false
    t.string "payment_id"
    t.string "payment_method_id"
    t.string "payment_provider", default: "stripe"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "payment_method_types", default: ["card"], array: true
    t.index ["payable_type", "payable_id"], name: "index_payments_on_payable"
  end

  create_table "private_chats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "created_by"
    t.string "users_list", default: [], array: true
    t.string "description"
    t.string "short_description"
    t.integer "participant_count", default: 2, null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "expert_id", null: false
    t.uuid "individual_id", null: false
    t.datetime "expiration_date", default: -> { "(CURRENT_TIMESTAMP + 'P7D'::interval)" }
    t.index ["expert_id"], name: "index_private_chats_on_expert_id"
    t.index ["individual_id"], name: "index_private_chats_on_individual_id"
  end

  create_table "quick_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "question", null: false
    t.text "answer"
    t.string "payment_id"
    t.string "payment_status"
    t.string "refund_id"
    t.uuid "expert_id", null: false
    t.uuid "individual_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description", null: false
    t.datetime "answer_date"
    t.integer "category_id"
    t.string "status", default: "pending"
    t.integer "rate", default: 0, null: false
    t.string "stripe_payment_method_id"
    t.integer "response_time"
    t.string "answer_type", default: "choose"
    t.index ["category_id"], name: "index_quick_questions_on_category_id"
    t.index ["expert_id"], name: "index_quick_questions_on_expert_id"
    t.index ["individual_id"], name: "index_quick_questions_on_individual_id"
  end

  create_table "refunds", force: :cascade do |t|
    t.string "refundable_type", null: false
    t.uuid "refundable_id", null: false
    t.string "payment_intent_id_ext"
    t.string "refund_id_ext"
    t.integer "amount"
    t.string "status"
    t.jsonb "refund_metadata", default: "{}", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reminders", force: :cascade do |t|
    t.float "timer"
    t.string "detail"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rescheduling_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "expert_call_id"
    t.string "rescheduled_by_type"
    t.uuid "rescheduled_by_id"
    t.string "rescheduling_reason", limit: 1000
    t.datetime "new_requested_start_time"
    t.string "status", default: "pending"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["expert_call_id"], name: "index_rescheduling_requests_on_expert_call_id"
    t.index ["rescheduled_by_type", "rescheduled_by_id"], name: "index_rescheduling_requests_on_rescheduled_by"
  end

  create_table "setting_variables", force: :cascade do |t|
    t.integer "question_response_time_in_days", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "territories", force: :cascade do |t|
    t.string "name", null: false
    t.string "alpha2_code", null: false
    t.string "phone_code", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "time_additions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "expert_call_id", null: false
    t.string "status"
    t.integer "duration"
    t.integer "rate"
    t.string "payment_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_id"
  end

  create_table "time_change_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "expert_call_id"
    t.string "requested_by_type"
    t.uuid "requested_by_id"
    t.string "reason", limit: 1000
    t.datetime "new_suggested_start_time"
    t.string "status", default: "pending"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["expert_call_id"], name: "index_time_change_requests_on_expert_call_id"
    t.index ["requested_by_type", "requested_by_id"], name: "index_time_change_requests_on_requested_by"
  end

  create_table "transactions", force: :cascade do |t|
    t.uuid "individual_id", null: false
    t.uuid "expert_id", null: false
    t.bigint "expert_interaction_id"
    t.integer "amount", null: false
    t.string "charge_type", null: false
    t.string "stripe_transaction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "time_addition_id"
    t.uuid "payment_id"
    t.index ["payment_id"], name: "index_transactions_on_payment_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.string "transferable_type", null: false
    t.uuid "transferable_id", null: false
    t.string "transfer_id_ext"
    t.integer "amount"
    t.string "destination_account_id_ext"
    t.string "balance_transaction_id_ext"
    t.string "destination_payment_id_ext"
    t.boolean "reversed"
    t.jsonb "transfer_metadata", default: "{}", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "admin", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name"
    t.string "last_name"
    t.boolean "active", default: true
    t.date "date_of_birth"
    t.string "gender"
    t.string "phone_number"
    t.string "country"
    t.string "city"
    t.string "zip_code"
    t.string "status", default: "registered"
    t.boolean "allow_notifications", default: false
    t.integer "current_role", default: 0, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "account_verified", default: false
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.boolean "phone_number_verified", default: false
    t.string "otp_backup_codes", array: true
    t.boolean "pending_to_delete", default: false
    t.boolean "is_default", default: false
    t.datetime "account_deletion_requested_at"
    t.string "phone"
    t.string "country_code", default: "+1"
    t.index "to_tsvector('simple'::regconfig, (((first_name)::text || ' '::text) || (last_name)::text))", name: "users_name_idx", using: :gin
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "account_deletion_follow_ups", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attachments", "messages"
  add_foreign_key "attachments", "quick_questions"
  add_foreign_key "availabilities", "experts"
  add_foreign_key "categories_experts", "categories"
  add_foreign_key "categories_experts", "experts"
  add_foreign_key "category_interactions", "categories"
  add_foreign_key "chat_rooms", "expert_calls"
  add_foreign_key "complaints", "expert_interactions"
  add_foreign_key "complaints", "experts"
  add_foreign_key "complaints", "individuals"
  add_foreign_key "devices", "users"
  add_foreign_key "expert_calls", "categories"
  add_foreign_key "expert_calls", "experts"
  add_foreign_key "expert_calls", "individuals"
  add_foreign_key "expert_interactions", "experts"
  add_foreign_key "experts", "users"
  add_foreign_key "guest_in_calls", "expert_calls"
  add_foreign_key "guest_in_calls", "individuals"
  add_foreign_key "individuals", "users"
  add_foreign_key "messages", "attachments"
  add_foreign_key "messages", "private_chats"
  add_foreign_key "participant_events", "expert_calls"
  add_foreign_key "payment_updates", "payments"
  add_foreign_key "private_chats", "experts"
  add_foreign_key "private_chats", "individuals"
  add_foreign_key "quick_questions", "experts"
  add_foreign_key "quick_questions", "individuals"
  add_foreign_key "time_additions", "expert_calls"
  add_foreign_key "transactions", "expert_interactions"
  add_foreign_key "transactions", "experts"
  add_foreign_key "transactions", "individuals"
  add_foreign_key "transactions", "payments"
end
