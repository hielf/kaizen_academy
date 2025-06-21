class AddPriceToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :courses, :price, :decimal, precision: 10, scale: 2, default: 0
  end
end
