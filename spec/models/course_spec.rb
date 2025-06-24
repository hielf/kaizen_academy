require 'rails_helper'

RSpec.describe Course, type: :model do
  describe 'associations' do
    it { should belong_to(:school) }
    it { should belong_to(:term) }
    it { should have_many(:enrollments).dependent(:restrict_with_error) }
    it { should have_many(:purchases).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { create(:course) }

    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title).scoped_to(:school_id).with_message("already exists for this school") }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe '#destroy' do
    let(:course) { create(:course) }

    context 'when the course has dependent records' do
      it 'prevents deletion if an enrollment exists' do
        create(:enrollment, course: course)
        expect { course.destroy }.not_to change(Course, :count)
        expect(course.errors[:base]).to include("Cannot delete record because dependent enrollments exist")
      end

      it 'prevents deletion if a purchase exists' do
        # Create a separate course to ensure isolation
        course_with_purchase = create(:course)
        create(:purchase, purchasable: course_with_purchase)
        expect { course_with_purchase.destroy }.not_to change(Course, :count)
        # Note: Purchase model has an after_create callback that creates an enrollment
        # So we get the enrollment error instead of the purchase error
        expect(course_with_purchase.errors[:base]).to include("Cannot delete record because dependent enrollments exist")
      end
    end

    context 'when course has no associated records' do
      it 'deletes the course' do
        course # ensure course is created
        expect { course.destroy }.to change(Course, :count).by(-1)
      end
    end
  end
end
