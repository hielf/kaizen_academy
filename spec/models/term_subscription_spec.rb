require 'rails_helper'

RSpec.describe TermSubscription, type: :model do
  describe 'associations' do
    it { should belong_to(:student).class_name('User').with_foreign_key('student_id') }
    it { should belong_to(:term) }
    it { should belong_to(:payment_method).optional }
    it { should have_many(:enrollments).dependent(:destroy) }
  end

  describe 'validations' do
    subject { create(:term_subscription) }

    it { should validate_presence_of(:student) }
    it { should validate_presence_of(:term) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[active expired pending cancelled]) }
    it { should validate_presence_of(:subscription_type) }
    it { should validate_inclusion_of(:subscription_type).in_array(%w[credit_card license admin_created]) }

    context 'uniqueness validation' do
      let(:student) { create(:student) }
      let(:term) { create(:term) }
      before do
        create(:term_subscription, student: student, term: term, status: 'active')
      end

      it 'prevents another active subscription for the same student and term' do
        new_subscription = build(:term_subscription, student: student, term: term, status: 'active')
        expect(new_subscription).not_to be_valid
        expect(new_subscription.errors[:student_id]).to include("already has an active subscription for this term")
      end

      it 'allows a non-active subscription' do
        new_subscription = build(:term_subscription, student: student, term: term, status: 'expired')
        expect(new_subscription).to be_valid
      end
    end
  end

  describe 'callbacks' do
    describe '#create_term_enrollments' do
      let(:student) { create(:student) }
      let(:term) { create(:term) }
      let!(:course1) { create(:course, term: term) }
      let!(:course2) { create(:course, term: term) }

      it 'creates enrollments for all courses in the term upon creation' do
        expect {
          create(:term_subscription, student: student, term: term)
        }.to change(Enrollment, :count).by(2)
      end

      it 'associates the new enrollments with the term subscription' do
        subscription = create(:term_subscription, student: student, term: term)
        expect(Enrollment.where(term_subscription: subscription).count).to eq(2)
        expect(subscription.enrollments.pluck(:course_id)).to contain_exactly(course1.id, course2.id)
      end
    end
  end

  describe '#active?' do
    it 'returns true for an active subscription within its date range' do
      subscription = create(:term_subscription, start_date: 1.day.ago, end_date: 1.day.from_now, status: 'active')
      expect(subscription).to be_active
    end

    it 'returns false for a subscription outside its date range' do
      subscription = create(:term_subscription, start_date: 2.days.ago, end_date: 1.day.ago, status: 'active')
      expect(subscription).not_to be_active
    end

    it 'returns false if status is not "active"' do
      subscription = create(:term_subscription, start_date: 1.day.ago, end_date: 1.day.from_now, status: 'expired')
      expect(subscription).not_to be_active
    end
  end
end
