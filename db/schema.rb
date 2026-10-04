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

ActiveRecord::Schema[8.1].define(version: 2026_10_04_000003) do
  create_table "customers", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "company"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.string "number", null: false
    t.integer "customer_id", null: false
    t.date "issue_date", null: false
    t.date "due_date", null: false
    t.string "status", default: "draft", null: false
    t.date "paid_date"
    t.text "notes"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
    t.index ["number"], name: "index_invoices_on_number", unique: true
  end

  create_table "line_items", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.string "description", null: false
    t.integer "quantity", null: false
    t.integer "unit_price_cents", null: false
    t.index ["invoice_id"], name: "index_line_items_on_invoice_id"
  end

  add_foreign_key "invoices", "customers"
  add_foreign_key "line_items", "invoices", on_delete: :cascade
end
