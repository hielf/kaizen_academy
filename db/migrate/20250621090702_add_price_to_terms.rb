class AddPriceToTerms < ActiveRecord::Migration[7.1]
  def change
    add_column :terms, :price, :decimal, precision: 10, scale: 2, default: 0
  end
end
