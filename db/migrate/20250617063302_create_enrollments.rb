class CreateEnrollments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrollments do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :course, null: false, foreign_key: true
      t.references :purchase, null: true, foreign_key: true # Nullable if not via direct purchase
      t.references :term_subscription, null: true, foreign_key: true # Nullable if not via term subscription
      t.date :join_date, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :access_status, null: false, default: 'active' # e.g., 'active', 'expired', 'pending'
      t.string :enrollment_method, null: false # e.g., 'direct_purchase', 'term_subscription', 'admin_override'

      t.timestamps
    end
    add_index :enrollments, [ :student_id, :course_id ], unique: true
  end
end
