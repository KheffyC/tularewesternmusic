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

ActiveRecord::Schema[7.0].define(version: 2026_07_28_120001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "amazon_pdfs", force: :cascade do |t|
    t.string "name"
    t.bigint "director_id"
    t.bigint "program_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type_of_pdf_group"
    t.date "event_date"
    t.string "document_url"
    t.index ["director_id"], name: "index_amazon_pdfs_on_director_id"
    t.index ["program_id"], name: "index_amazon_pdfs_on_program_id"
  end

  create_table "boosters", force: :cascade do |t|
    t.boolean "active"
    t.string "first_name"
    t.string "last_name"
    t.string "role"
    t.string "description"
    t.string "image_url"
    t.bigint "school_id", null: false
    t.string "email"
    t.string "phone_number"
    t.integer "years_involved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_boosters_on_school_id"
  end

  create_table "directors", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "title"
    t.string "school_name"
    t.string "school_address"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_directors_on_email", unique: true
    t.index ["reset_password_token"], name: "index_directors_on_reset_password_token", unique: true
  end

  create_table "districts", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "city"
    t.string "state"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_districts_on_name"
  end

  create_table "fundraisers", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "goal"
    t.string "call_to_action"
    t.string "main_image"
    t.bigint "program_id", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["program_id"], name: "index_fundraisers_on_program_id"
  end

  create_table "galleries", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.jsonb "images", default: [], null: false
    t.string "title", default: "Gallery", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_galleries_on_school_id"
  end

  create_table "programs", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "description"
    t.date "year_established"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "school_id", null: false
    t.string "main_gallery_image_url"
    t.string "about_image_url"
    t.string "hero_title", limit: 100
    t.string "detailed_description"
    t.string "short_name"
    t.string "image_gallery_urls"
    t.string "calendar_url"
    t.string "circuit", limit: 50
    t.string "ig_handle", limit: 50
    t.integer "period", default: 0
    t.text "program_support_text"
    t.index ["name"], name: "index_programs_on_name"
    t.index ["school_id"], name: "index_programs_on_school_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.date "established"
    t.string "description"
    t.string "city"
    t.string "state"
    t.string "district"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "district_id"
    t.string "hero_title", limit: 100
    t.string "call_to_action"
    t.string "contact_us"
    t.string "about"
    t.string "home_page_image_urls"
    t.string "calendar_url"
    t.string "director_name", limit: 255
    t.string "director_phone", limit: 255
    t.string "director_email", limit: 255
    t.string "percussion_director_name", limit: 255
    t.string "percussion_director_phone", limit: 255
    t.string "percussion_director_email", limit: 255
    t.string "default_image"
    t.string "performance_absence_form"
    t.string "rehearsal_absence_form"
    t.string "handbook_contract_form"
    t.string "about_hero_image"
    t.boolean "staff_enabled", default: false, null: false
    t.boolean "boosters_enabled", default: false, null: false
    t.boolean "fundraisers_enabled", default: false, null: false
    t.boolean "photo_gallery_enabled", default: false, null: false
    t.index ["district_id"], name: "index_schools_on_district_id"
    t.index ["name"], name: "index_schools_on_name"
  end

  create_table "staff_members", force: :cascade do |t|
    t.string "name", null: false
    t.string "title"
    t.text "bio"
    t.boolean "is_band_director", default: false, null: false
    t.integer "display_order", default: 0
    t.bigint "school_id", null: false
    t.bigint "program_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["program_id"], name: "index_staff_members_on_program_id"
    t.index ["school_id"], name: "index_staff_members_on_school_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "amazon_pdfs", "directors"
  add_foreign_key "amazon_pdfs", "programs"
  add_foreign_key "boosters", "schools"
  add_foreign_key "fundraisers", "programs"
  add_foreign_key "galleries", "schools"
  add_foreign_key "programs", "schools"
  add_foreign_key "schools", "districts"
  add_foreign_key "staff_members", "programs"
  add_foreign_key "staff_members", "schools"
end
