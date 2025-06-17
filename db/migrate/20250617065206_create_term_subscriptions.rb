class CreateTermSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :term_subscriptions do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :term, null: false, foreign_key: true

      t.references :payment_method, polymorphic: true, null: true # Nullable if admin_created

      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, null: false, default: 'active' # active, expired, pending, cancelled
      t.string :subscription_type, null: false # credit_card, license, admin_created

      t.timestamps
    end
    # Add a unique index to prevent duplicate active subscriptions for a student in a term
    add_index :term_subscriptions, [:student_id, :term_id], unique: true
  end
end
