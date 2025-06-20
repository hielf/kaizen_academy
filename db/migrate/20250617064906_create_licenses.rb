class CreateLicenses < ActiveRecord::Migration[8.0]
  def change
    create_table :licenses do |t|
      t.string :code, null: false, index: { unique: true } # Unique license code
      t.references :term, null: false, foreign_key: true # License is for a specific term
      t.datetime :issued_at, null: false
      t.datetime :redeemed_at, null: true # Nullable if not redeemed yet
      t.datetime :expires_at, null: false
      t.string :status, null: false, default: 'active' # e.g., 'active', 'redeemed', 'expired', 'invalid'

      t.timestamps
    end

    add_index :licenses, [ :term_id, :code ], unique: true
  end
end
