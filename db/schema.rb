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

ActiveRecord::Schema[8.0].define(version: 2025_06_17_065206) do
  create_table "courses", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.integer "school_id", null: false
    t.integer "term_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_courses_on_school_id"
    t.index ["term_id"], name: "index_courses_on_term_id"
    t.index ["title", "school_id"], name: "index_courses_on_title_and_school_id", unique: true
  end

  create_table "credit_card_payments", force: :cascade do |t|
    t.string "last_four", null: false
    t.string "expiry_date", null: false
    t.string "card_type", null: false
    t.datetime "processed_at", default: -> { "NOW()" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "course_id", null: false
    t.integer "purchase_id"
    t.integer "term_subscription_id"
    t.date "join_date", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "access_status", default: "active", null: false
    t.string "enrollment_method", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["purchase_id"], name: "index_enrollments_on_purchase_id"
    t.index ["student_id", "course_id"], name: "index_enrollments_on_student_id_and_course_id", unique: true
    t.index ["student_id"], name: "index_enrollments_on_student_id"
    t.index ["term_subscription_id"], name: "index_enrollments_on_term_subscription_id"
  end

  create_table "licenses", force: :cascade do |t|
    t.string "code", null: false
    t.integer "term_id", null: false
    t.datetime "issued_at", null: false
    t.datetime "redeemed_at"
    t.datetime "expires_at", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_licenses_on_code", unique: true
    t.index ["term_id", "code"], name: "index_licenses_on_term_id_and_code", unique: true
    t.index ["term_id"], name: "index_licenses_on_term_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "course_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "transaction_id"
    t.datetime "purchased_at", default: -> { "NOW()" }, null: false
    t.integer "enrollment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_purchases_on_course_id"
    t.index ["enrollment_id"], name: "index_purchases_on_enrollment_id"
    t.index ["student_id"], name: "index_purchases_on_student_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_schools_on_name", unique: true
  end

  create_table "term_subscriptions", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "term_id", null: false
    t.string "payment_method_type"
    t.integer "payment_method_id"
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "status", default: "active", null: false
    t.string "subscription_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_method_type", "payment_method_id"], name: "index_term_subscriptions_on_payment_method"
    t.index ["student_id", "term_id"], name: "index_term_subscriptions_on_student_id_and_term_id", unique: true
    t.index ["student_id"], name: "index_term_subscriptions_on_student_id"
    t.index ["term_id"], name: "index_term_subscriptions_on_term_id"
  end

  create_table "terms", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.integer "school_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "name"], name: "index_terms_on_school_id_and_name", unique: true
    t.index ["school_id"], name: "index_terms_on_school_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "type", default: "Student", null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
    t.index ["type"], name: "index_users_on_type"
  end

  add_foreign_key "courses", "schools"
  add_foreign_key "courses", "terms"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "purchases"
  add_foreign_key "enrollments", "term_subscriptions"
  add_foreign_key "enrollments", "users", column: "student_id"
  add_foreign_key "licenses", "terms"
  add_foreign_key "purchases", "courses"
  add_foreign_key "purchases", "enrollments"
  add_foreign_key "purchases", "users", column: "student_id"
  add_foreign_key "term_subscriptions", "terms"
  add_foreign_key "term_subscriptions", "users", column: "student_id"
  add_foreign_key "terms", "schools"
  add_foreign_key "users", "schools"
end
