require 'rails_helper'

RSpec.describe Admin, type: :model do
  let(:admin) { build(:admin) }

  describe "inheritance" do
    it "inherits from User" do
      expect(admin).to be_a(User)
    end

    it "has a type of 'Admin'" do
      expect(admin.type).to eq('Admin')
    end

    it "is an admin" do
      expect(admin.admin?).to be true
      expect(admin.student?).to be false
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(admin).to be_valid
    end

    it "is not valid without an email" do
      admin.email = nil
      expect(admin).not_to be_valid
      expect(admin.errors[:email]).to include("can't be blank")
    end

    it "is not valid with a duplicate email" do
      create(:admin, email: 'admin@example.com')
      admin.email = 'admin@example.com'
      expect(admin).not_to be_valid
      expect(admin.errors[:email]).to include("has already been taken")
    end

    it "is not valid without first_name" do
      admin.first_name = nil
      expect(admin).not_to be_valid
      expect(admin.errors[:first_name]).to include("can't be blank")
    end

    it "is not valid without last_name" do
      admin.last_name = nil
      expect(admin).not_to be_valid
      expect(admin.errors[:last_name]).to include("can't be blank")
    end

    it "is not valid without type" do
      admin.type = nil
      expect(admin).not_to be_valid
      expect(admin.errors[:type]).to include("can't be blank")
    end

    describe "email format validation" do
      it "accepts valid email addresses" do
        valid_emails = [
          'admin@example.com',
          'admin.name@example.com',
          'admin+tag@example.co.uk',
          'admin123@example-domain.org'
        ]

        valid_emails.each do |email|
          admin.email = email
          expect(admin).to be_valid, "Expected #{email} to be valid"
        end
      end

      it "rejects invalid email addresses" do
        invalid_emails = [
          'invalid',
          '@example.com',
          'admin@',
          'admin@.com',
          'admin@example',
          'admin@example.',
          'admin@example..com',
          'admin@example.c',
          'a@example.com' # local part too short
        ]

        invalid_emails.each do |email|
          admin.email = email
          expect(admin).not_to be_valid, "Expected #{email} to be invalid"
          expect(admin.errors[:email]).to be_present
        end
      end

      it "rejects email with local part less than 2 characters" do
        admin.email = 'a@example.com'
        expect(admin).not_to be_valid
        expect(admin.errors[:email]).to include("local part must be at least 2 characters")
      end

      it "rejects email with invalid domain structure" do
        admin.email = 'admin@example'
        expect(admin).not_to be_valid
        expect(admin.errors[:email]).to include("domain must be properly formatted (e.g., example.com)")
      end

      it "rejects email with domain extension less than 2 characters" do
        admin.email = 'admin@example.c'
        expect(admin).not_to be_valid
        expect(admin.errors[:email]).to include("domain extension must be at least 2 characters")
      end
    end
  end

  describe "associations" do
    it "belongs to school optionally" do
      expect(admin.school).to be_nil
      expect(admin).to be_valid
    end

    it "can have an optional school association" do
      school = create(:school)
      admin.school = school
      expect(admin).to be_valid
      expect(admin.school).to eq(school)
    end
  end

  describe "Devise modules" do
    it "includes database_authenticatable" do
      expect(Admin.devise_modules).to include(:database_authenticatable)
    end

    it "includes registerable" do
      expect(Admin.devise_modules).to include(:registerable)
    end

    it "includes recoverable" do
      expect(Admin.devise_modules).to include(:recoverable)
    end

    it "includes rememberable" do
      expect(Admin.devise_modules).to include(:rememberable)
    end

    it "includes validatable" do
      expect(Admin.devise_modules).to include(:validatable)
    end
  end

  describe "#after_sign_in_path_for" do
    it "redirects to root path" do
      expect(admin.after_sign_in_path_for(admin)).to eq("/")
    end
  end

  describe "role checking methods" do
    it "has student? method" do
      expect(admin).to respond_to(:student?)
    end

    it "has admin? method" do
      expect(admin).to respond_to(:admin?)
    end

    it "returns correct role values" do
      expect(admin.admin?).to be true
      expect(admin.student?).to be false
    end
  end

  describe "factory" do
    it "has a valid admin factory" do
      expect(build(:admin)).to be_valid
    end

    it "creates an admin with correct type" do
      admin = create(:admin)
      expect(admin.type).to eq('Admin')
      expect(admin).to be_a(Admin)
    end
  end
end 