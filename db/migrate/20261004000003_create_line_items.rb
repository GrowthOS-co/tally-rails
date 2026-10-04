class CreateLineItems < ActiveRecord::Migration[8.1]
  def change
    create_table :line_items do |t|
      t.references :invoice, null: false, foreign_key: { on_delete: :cascade }
      t.string :description, null: false
      t.integer :quantity, null: false
      t.integer :unit_price_cents, null: false
    end
  end
end
