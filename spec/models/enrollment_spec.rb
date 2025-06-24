require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  describe 'associations' do
    it { should belong_to(:student).class_name('User').with_foreign_key('student_id') }
    it { should belong_to(:course) }
    it { should belong_to(:purchase).optional }
    it { should belong_to(:term_subscription).optional }
  end

  describe 'validations' do
    subject { create(:enrollment) }

    it { should validate_presence_of(:student) }
    it { should validate_presence_of(:course) }
    it { should validate_presence_of(:join_date) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:access_status) }
    it { should validate_presence_of(:enrollment_method) }

    it { should validate_uniqueness_of(:student_id).scoped_to(:course_id).with_message("is already enrolled in this course") }

    it { should validate_inclusion_of(:enrollment_method).in_array(%w[direct_purchase term_subscription admin_override term_subscription_credit_card term_subscription_license term_subscription_admin]) }
  end

  describe 'callbacks' do
    it 'sets join_date on creation' do
      enrollment = build(:enrollment, join_date: nil)
      enrollment.save!
      expect(enrollment.join_date).to be_present
    end

    it 'sets default access_status to "active" on creation' do
      enrollment = build(:enrollment, access_status: nil)
      enrollment.save!
      expect(enrollment.access_status).to eq('active')
    end
  end

  describe '#active?' do
    it 'returns true for an active enrollment within its date range' do
      enrollment = create(:enrollment, start_date: 1.day.ago, end_date: 1.day.from_now, access_status: 'active')
      expect(enrollment).to be_active
    end

    it 'returns false for an enrollment outside its date range' do
      enrollment = create(:enrollment, start_date: 2.days.ago, end_date: 1.day.ago, access_status: 'active')
      expect(enrollment).not_to be_active
    end

    it 'returns false if access_status is not "active"' do
      enrollment = create(:enrollment, start_date: 1.day.ago, end_date: 1.day.from_now, access_status: 'inactive')
      expect(enrollment).not_to be_active
    end
  end

  describe '.enroll!' do
    let(:student) { create(:student) }
    let(:course) { create(:course) }

    context 'with minimal parameters' do
      it 'creates an enrollment' do
        expect {
          Enrollment.enroll!(student: student, course: course, enrollment_method: 'admin_override', end_date: 1.year.from_now)
        }.to change(Enrollment, :count).by(1)
      end

      it 'uses the course term dates if available' do
        term = create(:term, start_date: 1.month.from_now, end_date: 4.months.from_now)
        course.update(term: term)
        enrollment = Enrollment.enroll!(student: student, course: course, enrollment_method: 'admin_override')
        expect(enrollment.start_date.to_date).to eq(term.start_date)
        expect(enrollment.end_date.to_date).to eq(term.end_date)
      end
    end

    context 'with a term subscription' do
      let(:term) { create(:term, start_date: 1.week.from_now, end_date: 2.months.from_now) }
      let(:term_subscription) { create(:term_subscription, student: student, term: term) }

      it 'uses the term subscription dates' do
        enrollment = Enrollment.enroll!(student: student, course: course, enrollment_method: 'term_subscription', term_subscription: term_subscription)
        expect(enrollment.start_date).to eq(term_subscription.start_date)
        expect(enrollment.end_date).to eq(term_subscription.end_date)
      end
    end

    context 'when end_date is missing' do
      it 'raises an error if end_date cannot be determined' do
        course.update(term: nil) # Ensure no term is set
        expect {
          Enrollment.enroll!(student: student, course: course, enrollment_method: 'admin_override')
        }.to raise_error("End date must be provided for enrollment")
      end
    end

    it 'associates the purchase if provided' do
      purchase = create(:purchase, student: student, purchasable: course)
      # The enrollment is created by the after_create callback on the Purchase model.
      # We just need to find it and check its association.
      enrollment = Enrollment.find_by(purchase: purchase)
      expect(enrollment).to be_present
      expect(enrollment.purchase).to eq(purchase)
      expect(enrollment.student).to eq(student)
      expect(enrollment.course).to eq(course)
    end
  end
end
