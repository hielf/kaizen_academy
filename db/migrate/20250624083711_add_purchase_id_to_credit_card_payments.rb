class AddPurchaseIdToCreditCardPayments < ActiveRecord::Migration[8.0]
  def change
    add_reference :credit_card_payments, :purchase, null: true, foreign_key: true
  end
end
