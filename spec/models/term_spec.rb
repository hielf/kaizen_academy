require 'rails_helper'

RSpec.describe Term, type: :model do
  describe 'associations' do
    it { should belong_to(:school) }
    it { should have_many(:courses).dependent(:restrict_with_error) }
    it { should have_many(:term_subscriptions).dependent(:restrict_with_error) }
    it { should have_many(:students).through(:term_subscriptions) }
    it { should have_many(:purchases).dependent(:restrict_with_error) }
    it { should have_many(:enrollments).through(:courses) }
    it { should have_many(:licenses).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { create(:term) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:school_id).with_message("already exists for this school") }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }

    it 'validates that end_date is after start_date' do
      term = build(:term, start_date: Time.zone.today, end_date: Time.zone.today - 1.day)
      expect(term).not_to be_valid
      expect(term.errors[:end_date]).to include('must be after the start date')
    end
  end

  describe 'scopes' do
    let!(:school) { create(:school) }
    let!(:active_term) { create(:term, school: school, start_date: 1.month.ago, end_date: 1.month.from_now) }
    let!(:upcoming_term) { create(:term, school: school, start_date: 1.month.from_now, end_date: 3.months.from_now) }
    let!(:expired_term) { create(:term, school: school, start_date: 3.months.ago, end_date: 1.month.ago) }
    let!(:other_school_active_term) { create(:term, start_date: 1.week.ago, end_date: 1.week.from_now) }
    let!(:other_school_upcoming_term) { create(:term, start_date: 1.week.from_now, end_date: 2.weeks.from_now) }

    it '.available returns active and upcoming terms' do
      expect(Term.available).to contain_exactly(active_term, upcoming_term, other_school_active_term, other_school_upcoming_term)
    end

    it '.active returns terms that are currently active' do
      expect(Term.active).to contain_exactly(active_term, other_school_active_term)
    end

    it '.upcoming returns terms that are yet to start' do
      expect(Term.upcoming).to contain_exactly(upcoming_term, other_school_upcoming_term)
    end

    it '.expired returns terms that have ended' do
      expect(Term.expired).to contain_exactly(expired_term)
    end

    it '.for_school returns terms for a specific school' do
      expect(Term.for_school(school)).to contain_exactly(active_term, upcoming_term, expired_term)
    end
  end

  describe '#available?' do
    it 'returns true for a term that has not ended' do
      term = build(:term, end_date: 1.day.from_now)
      expect(term).to be_available
    end

    it 'returns false for a term that has ended' do
      term = build(:term, end_date: 1.day.ago)
      expect(term).not_to be_available
    end
  end

  describe '#destroy' do
    let(:term) { create(:term) }

    context 'when term has associated courses' do
      before { create(:course, term: term) }
      it 'does not delete the term' do
        expect { term.destroy }.not_to change(Term, :count)
        expect(term.errors[:base]).to include("Cannot delete record because dependent courses exist")
      end
    end

    context 'when term has associated term subscriptions' do
      before { create(:term_subscription, term: term) }
      it 'does not delete the term' do
        expect { term.destroy }.not_to change(Term, :count)
        expect(term.errors[:base]).to include("Cannot delete record because dependent term subscriptions exist")
      end
    end

    context 'when term has associated purchases' do
      before { create(:purchase, purchasable: term) }
      it 'does not delete the term' do
        expect { term.destroy }.not_to change(Term, :count)
        expect(term.errors[:base]).to include("Cannot delete record because dependent purchases exist")
      end
    end

    context 'when term has associated licenses' do
      before { create(:license, term: term) }
      it 'does not delete the term' do
        expect { term.destroy }.not_to change(Term, :count)
        expect(term.errors[:base]).to include("Cannot delete record because dependent licenses exist")
      end
    end

    context 'when term has no dependent records' do
      it 'deletes the term' do
        term # create term
        expect { term.destroy }.to change(Term, :count).by(-1)
      end
    end
  end
end
