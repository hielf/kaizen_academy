class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.references :school, null: false, foreign_key: true
      t.references :term, null: false, foreign_key: true

      t.timestamps
    end
    add_index :courses, [:title, :school_id], unique: true
  end
end
