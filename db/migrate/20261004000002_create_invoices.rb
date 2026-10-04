class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.string :number, null: false, index: { unique: true }
      t.references :customer, null: false, foreign_key: true
      t.date :issue_date, null: false
      t.date :due_date, null: false
      t.string :status, null: false, default: "draft"
      t.date :paid_date
      t.text :notes
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
