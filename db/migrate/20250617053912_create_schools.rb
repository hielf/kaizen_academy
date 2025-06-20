class CreateSchools < ActiveRecord::Migration[8.0]
  def change
    create_table :schools do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :status, null: false, default: 'active'

      t.timestamps
    end
  end
end
