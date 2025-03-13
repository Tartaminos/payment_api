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

ActiveRecord::Schema[7.2].define(version: 2025_03_13_050251) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "installment_fees", force: :cascade do |t|
    t.integer "installments"
    t.decimal "fee_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.decimal "amount"
    t.integer "installment"
    t.string "payment_method"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_payment_transactions_on_created_at"
    t.index ["payment_method"], name: "index_payment_transactions_on_payment_method"
  end

  create_table "receivables", force: :cascade do |t|
    t.bigint "payment_transaction_id", null: false
    t.integer "installment"
    t.date "schedule_date"
    t.date "liquidation_date"
    t.string "status"
    t.decimal "amount_to_settle"
    t.decimal "amount_settled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_transaction_id"], name: "index_receivables_on_payment_transaction_id"
    t.index ["schedule_date", "status"], name: "index_receivables_on_schedule_date_and_status"
    t.index ["status"], name: "index_receivables_on_status", where: "((status)::text = 'aprovado'::text)"
  end

  add_foreign_key "receivables", "payment_transactions"
end
