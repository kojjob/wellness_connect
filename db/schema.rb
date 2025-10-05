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

ActiveRecord::Schema[8.1].define(version: 2025_10_05_044007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "availability_id"
    t.text "cancellation_reason"
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.bigint "patient_id", null: false
    t.bigint "provider_id", null: false
    t.bigint "service_id", null: false
    t.datetime "start_time"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.string "video_session_id"
    t.index ["availability_id"], name: "index_appointments_on_availability_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["provider_id"], name: "index_appointments_on_provider_id"
    t.index ["service_id"], name: "index_appointments_on_service_id"
  end

  create_table "availabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.boolean "is_booked", default: false
    t.bigint "provider_profile_id", null: false
    t.datetime "start_time"
    t.datetime "updated_at", null: false
    t.index ["provider_profile_id"], name: "index_availabilities_on_provider_profile_id"
  end

  create_table "consultation_notes", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_consultation_notes_on_appointment_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "action_url"
    t.datetime "created_at", null: false
    t.text "message"
    t.string "notification_type"
    t.datetime "read_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "patient_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.text "health_goals"
    t.text "medical_history_summary"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_patient_profiles_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount"
    t.bigint "appointment_id"
    t.datetime "created_at", null: false
    t.string "currency", default: "USD"
    t.datetime "paid_at"
    t.bigint "payer_id", null: false
    t.integer "status"
    t.string "stripe_payment_intent_id"
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_payments_on_appointment_id"
    t.index ["payer_id"], name: "index_payments_on_payer_id"
    t.index ["stripe_payment_intent_id"], name: "index_payments_on_stripe_payment_intent_id"
  end

  create_table "provider_profiles", force: :cascade do |t|
    t.text "areas_of_expertise"
    t.decimal "average_rating"
    t.text "bio"
    t.text "certifications"
    t.decimal "consultation_rate"
    t.datetime "created_at", null: false
    t.text "credentials"
    t.text "education"
    t.string "facebook_url"
    t.text "industries_served"
    t.string "instagram_url"
    t.text "languages"
    t.string "linkedin_url"
    t.text "office_address"
    t.text "philosophy"
    t.string "phone"
    t.text "session_formats"
    t.string "specialty"
    t.integer "total_reviews"
    t.text "treatment_modalities"
    t.string "twitter_url"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "website"
    t.integer "years_of_experience"
    t.index ["user_id"], name: "index_provider_profiles_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at", null: false
    t.bigint "provider_profile_id", null: false
    t.integer "rating", null: false
    t.bigint "reviewer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_profile_id", "created_at"], name: "index_reviews_on_provider_and_date"
    t.index ["provider_profile_id"], name: "index_reviews_on_provider_profile_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    t.check_constraint "rating >= 1 AND rating <= 5", name: "rating_range_check"
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration_minutes"
    t.boolean "is_active", default: true
    t.string "name"
    t.decimal "price"
    t.bigint "provider_profile_id", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_profile_id"], name: "index_services_on_provider_profile_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "blocked_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.text "status_reason"
    t.datetime "suspended_at"
    t.string "time_zone", default: "UTC"
    t.datetime "updated_at", null: false
    t.index ["blocked_at"], name: "index_users_on_blocked_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["suspended_at"], name: "index_users_on_suspended_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointments", "availabilities"
  add_foreign_key "appointments", "services"
  add_foreign_key "appointments", "users", column: "patient_id"
  add_foreign_key "appointments", "users", column: "provider_id"
  add_foreign_key "availabilities", "provider_profiles"
  add_foreign_key "consultation_notes", "appointments"
  add_foreign_key "notifications", "users"
  add_foreign_key "patient_profiles", "users"
  add_foreign_key "payments", "appointments"
  add_foreign_key "payments", "users", column: "payer_id"
  add_foreign_key "provider_profiles", "users"
  add_foreign_key "reviews", "provider_profiles"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "services", "provider_profiles"
end
