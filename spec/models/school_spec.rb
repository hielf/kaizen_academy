require 'rails_helper'

RSpec.describe School, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(255) }
  end

  describe 'associations' do
    it { should have_many(:terms) }
    it { should have_many(:courses) }
    it { should have_many(:students) }
  end

  describe 'deletion validation' do
    let(:school) { create(:school) }

    context 'when school has no associated records' do
      it 'can be deleted' do
        expect { school.destroy }.to change(School, :count).by(-1)
      end
    end

    context 'when school has associated terms' do
      before { create(:term, school: school) }

      it 'cannot be deleted' do
        expect { school.destroy }.not_to change(School, :count)
        expect(school.errors[:base]).to include('Cannot delete school with associated terms')
      end
    end

    context 'when school has associated courses' do
      let(:term) { create(:term, school: school) }
      before { create(:course, school: school, term: term) }

      it 'cannot be deleted' do
        expect { school.destroy }.not_to change(School, :count)
        expect(school.errors[:base]).to include('Cannot delete school with associated courses')
      end
    end

    context 'when school has associated students' do
      before { create(:student, school: school) }

      it 'cannot be deleted' do
        expect { school.destroy }.not_to change(School, :count)
        expect(school.errors[:base]).to include('Cannot delete school with associated students')
      end
    end

    context 'when school has multiple types of associated records' do
      let(:term) { create(:term, school: school) }
      
      before do
        create(:term, school: school)
        create(:course, school: school, term: term)
        create(:student, school: school)
      end

      it 'cannot be deleted and shows all relevant error messages' do
        expect { school.destroy }.not_to change(School, :count)
        expect(school.errors[:base]).to include('Cannot delete school with associated terms')
        expect(school.errors[:base]).to include('Cannot delete school with associated courses')
        expect(school.errors[:base]).to include('Cannot delete school with associated students')
      end
    end
  end
end
