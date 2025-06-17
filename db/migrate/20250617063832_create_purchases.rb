class CreatePurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :purchases do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :course, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :transaction_id # Store transaction ID from payment gateway (simulated)
      t.datetime :purchased_at, null: false, default: -> { 'NOW()' } # Default to current time
      t.references :enrollment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
