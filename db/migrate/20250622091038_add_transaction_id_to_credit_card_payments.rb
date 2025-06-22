class AddTransactionIdToCreditCardPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :credit_card_payments, :transaction_id, :string
  end
end
