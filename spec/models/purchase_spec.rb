require 'rails_helper'

RSpec.describe Purchase, type: :model do
  describe 'associations' do
    it { should belong_to(:student).class_name('User').with_foreign_key('student_id') }
    it { should belong_to(:purchasable) }
    # Note: The `has_one :enrollment` is potentially misleading.
    # When a Term is purchased, multiple enrollments can be created.
    # This association will only return one of them.
    it { should have_one(:enrollment).dependent(:destroy) }
    it { should have_one(:credit_card_payment).dependent(:nullify) }
  end

  describe 'validations' do
    subject { create(:purchase) }
    it { should validate_presence_of(:student) }
    it { should validate_presence_of(:purchasable) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:purchased_at) }
  end

  describe 'callbacks' do
    describe '#create_enrollment after_create' do
      let(:student) { create(:student) }

      context 'when purchasable is a Course' do
        let(:course) { create(:course) }

        it 'creates one enrollment' do
          expect {
            create(:purchase, student: student, purchasable: course)
          }.to change(Enrollment, :count).by(1)
        end

        it 'associates the new enrollment with the purchase' do
          purchase = create(:purchase, student: student, purchasable: course)
          enrollment = Enrollment.last
          expect(enrollment.purchase).to eq(purchase)
          expect(enrollment.student).to eq(student)
          expect(enrollment.course).to eq(course)
        end
      end

      context 'when purchasable is a Term' do
        let(:term) { create(:term) }
        let!(:course1) { create(:course, term: term) }
        let!(:course2) { create(:course, term: term) }

        it 'creates enrollments for each course in the term' do
          expect {
            create(:purchase, student: student, purchasable: term)
          }.to change(Enrollment, :count).by(2)
        end

        it 'associates the new enrollments correctly' do
          purchase = create(:purchase, student: student, purchasable: term)
          enrollments = Enrollment.last(2)
          expect(enrollments.map(&:student).uniq).to eq([student])
          expect(enrollments.map(&:course)).to contain_exactly(course1, course2)
          expect(enrollments.map(&:purchase).uniq).to eq([purchase])
        end

        context 'when student is already enrolled in some courses in the term' do
          before do
            # Create an existing enrollment for course1
            create(:enrollment, student: student, course: course1, enrollment_method: 'admin_override')
          end

          it 'creates term purchase successfully and only enrolls in non-enrolled courses' do
            expect {
              create(:purchase, student: student, purchasable: term)
            }.to change(Enrollment, :count).by(1) # Only course2 should be enrolled
          end

          it 'only creates enrollments for courses the student is not already enrolled in' do
            purchase = create(:purchase, student: student, purchasable: term)
            new_enrollments = Enrollment.where(purchase: purchase)
            expect(new_enrollments.count).to eq(1)
            expect(new_enrollments.first.course).to eq(course2)
          end

          it 'does not create duplicate enrollments for already enrolled courses' do
            purchase = create(:purchase, student: student, purchasable: term)
            expect(student.enrollments.where(course: course1).count).to eq(1)
            expect(student.enrollments.where(course: course2).count).to eq(1)
          end
        end
      end

      context 'when purchasable is a Term with no courses' do
        let(:term_without_courses) { create(:term) }

        it 'does not create any enrollments' do
          expect {
            create(:purchase, student: student, purchasable: term_without_courses)
          }.not_to change(Enrollment, :count)
        end
      end
    end
  end
end
