class CreateCreditCardPayments < ActiveRecord::Migration[8.0]
  def change
    create_table :credit_card_payments do |t|
      t.string :last_four, null: false  
      t.string :expiry_date, null: false
      t.string :card_type, null: false
      t.datetime :processed_at, null: false, default: -> { 'NOW()' }

      t.timestamps
    end
  end
end
