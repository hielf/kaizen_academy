class ModifyPurchasesForPolymorphicRelationship < ActiveRecord::Migration[8.0]
  def change
    # Remove the direct course reference
    remove_reference :purchases, :course, foreign_key: true
    
    # Remove the enrollment reference (enrollments will reference purchases instead)
    remove_reference :purchases, :enrollment, foreign_key: true
    
    # Add polymorphic columns for purchasable (Term or Course)
    add_reference :purchases, :purchasable, polymorphic: true, null: false, index: true
  end
end
