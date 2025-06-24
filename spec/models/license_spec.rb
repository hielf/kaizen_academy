require 'rails_helper'

RSpec.describe License, type: :model do
  describe 'associations' do
    it { should belong_to(:term) }
    it { should have_one(:term_subscription).dependent(:nullify) }
  end

  describe 'validations' do
    subject { create(:license) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }
    it { should validate_presence_of(:term) }
    it { should validate_presence_of(:issued_at) }
    it { should validate_presence_of(:expires_at) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[active redeemed expired invalid]) }

    it 'validates that expires_at is after issued_at' do
      license = build(:license, issued_at: Time.current, expires_at: Time.current - 1.day)
      expect(license).not_to be_valid
      expect(license.errors[:expires_at]).to include('must be after issued date')
    end

    it 'validates presence of redeemed_at if status is redeemed' do
      license = build(:license, status: 'redeemed', redeemed_at: nil)
      expect(license).not_to be_valid
      expect(license.errors[:redeemed_at]).to include("can't be blank")
    end

    it 'is valid if status is not redeemed and redeemed_at is nil' do
      license = build(:license, status: 'active', redeemed_at: nil)
      expect(license).to be_valid
    end
  end

  describe 'callbacks' do
    it 'generates a unique code on creation' do
      license = build(:license, code: nil)
      license.save!
      expect(license.code).to be_present
    end

    it 'sets default status to "active" on creation' do
      license = build(:license, status: nil)
      license.save!
      expect(license.status).to eq('active')
    end

    it 'sets redeemed_at when status is updated to redeemed' do
      license = create(:license, status: 'active')
      license.update(status: 'redeemed')
      expect(license.redeemed_at).to be_present
    end
  end

  describe '#destroy' do
    context 'when license is redeemed' do
      it 'prevents destruction' do
        license = create(:license, :redeemed)
        expect { license.destroy }.not_to change(License, :count)
        expect(license.errors[:base]).to include('Cannot destroy a redeemed license')
      end
    end

    context 'when license is not redeemed' do
      it 'destroys the license' do
        license = create(:license, status: 'active')
        expect { license.destroy }.to change(License, :count).by(-1)
      end
    end
  end

  describe 'instance methods' do
    let(:term) { create(:term) }
    let(:student) { create(:student) }

    describe '#active?' do
      it 'returns true for an active, unredeemed license within its validity period' do
        license = create(:license, status: 'active', issued_at: 1.day.ago, expires_at: 1.day.from_now, redeemed_at: nil)
        expect(license.active?).to be true
      end

      it 'returns false if the status is not active' do
        license = create(:license, :expired)
        expect(license.active?).to be false
      end

      it 'returns false if it is expired' do
        license = create(:license, :expired)
        expect(license.active?).to be false
      end

      it 'returns false if it is redeemed' do
        license = create(:license, :redeemed)
        expect(license.active?).to be false
      end
    end

    describe '#redeemed?' do
      it 'returns true if status is redeemed and redeemed_at is set' do
        license = create(:license, :redeemed)
        expect(license.redeemed?).to be true
      end

      it 'returns false if status is not redeemed' do
        license = create(:license, status: 'active')
        expect(license.redeemed?).to be false
      end
    end

    describe '#expired?' do
      it 'returns true if status is "expired"' do
        license = create(:license, :expired)
        expect(license.expired?).to be true
      end

      it 'returns true if the expiration date is in the past' do
        license = create(:license, :expired)
        expect(license.expired?).to be true
      end

      it 'returns false for an active license' do
        license = create(:license, status: 'active', expires_at: 1.day.from_now)
        expect(license.expired?).to be false
      end
    end

    describe '#redeem!' do
      let(:active_license) { create(:license, term: term, status: 'active') }

      context 'with a valid, active license' do
        it 'returns true' do
          expect(active_license.redeem!(student)).to be true
        end

        it 'changes the license status to "redeemed"' do
          active_license.redeem!(student)
          expect(active_license.status).to eq('redeemed')
        end

        it 'sets the redeemed_at timestamp' do
          active_license.redeem!(student)
          expect(active_license.redeemed_at).to be_present
        end

        it 'creates a new TermSubscription' do
          expect { active_license.redeem!(student) }.to change(TermSubscription, :count).by(1)
        end

        it 'associates the new TermSubscription with the license' do
          active_license.redeem!(student)
          subscription = TermSubscription.last
          expect(subscription.payment_method).to eq(active_license)
          expect(subscription.student).to eq(student)
          expect(subscription.term).to eq(term)
        end
      end

      context 'with an invalid or inactive license' do
        it 'returns false for an expired license' do
          expired_license = create(:license, :expired)
          expect(expired_license.redeem!(student)).to be false
        end

        it 'returns false for an already redeemed license' do
          redeemed_license = create(:license, :redeemed)
          expect(redeemed_license.redeem!(student)).to be false
        end

        it 'does not create a new TermSubscription' do
          expired_license = create(:license, :expired)
          expect { expired_license.redeem!(student) }.not_to change(TermSubscription, :count)
        end
      end
    end
  end
end
