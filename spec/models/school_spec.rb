require 'rails_helper'

RSpec.describe School, type: :model do
  describe 'associations' do
    it { should have_many(:terms).dependent(:restrict_with_error) }
    it { should have_many(:courses).dependent(:restrict_with_error) }
    it { should have_many(:students).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { create(:school) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(255) }
  end

  describe '#destroy' do
    let!(:school) { create(:school) }

    context 'when school has no associated records' do
      it 'can be deleted' do
        expect { school.destroy }.to change(School, :count).by(-1)
      end
    end

    context 'when school has associated terms' do
      before { create(:term, school: school) }
      it 'cannot be deleted' do
        expect { school.destroy }.not_to change(School, :count)
        expect(school.errors[:base]).to include('Cannot delete record because dependent terms exist')
      end
    end

    context 'when school has associated courses' do
      # Create a course that belongs to this school, but whose term
      # belongs to another school. This isolates the course dependency.
      let(:other_school) { create(:school) }
      let(:term_from_other_school) { create(:term, school: other_school) }
      let!(:course) { create(:course, school: school, term: term_from_other_school) }

      it 'cannot be deleted' do
        expect { school.destroy }.not_to change(School, :count)
        expect(school.errors[:base]).to include('Cannot delete record because dependent courses exist')
      end
    end

    context 'when school has associated students' do
      before { create(:student, school: school) }
      it 'cannot be deleted' do
        expect { school.destroy }.not_to change(School, :count)
        expect(school.errors[:base]).to include('Cannot delete record because dependent students exist')
      end
    end
  end
end
