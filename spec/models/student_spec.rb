require 'rails_helper'

RSpec.describe Student, type: :model do
  let(:school) { create(:school) }
  let(:student) { build(:student, school: school) }

  describe "inheritance" do
    it "inherits from User" do
      expect(student).to be_a(User)
    end

    it "has a type of 'Student'" do
      expect(student.type).to eq('Student')
    end

    it "is a student" do
      expect(student.student?).to be true
      expect(student.admin?).to be false
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(student).to be_valid
    end

    it "is not valid without an email" do
      student.email = nil
      expect(student).not_to be_valid
      expect(student.errors[:email]).to include("can't be blank")
    end

    it "is not valid with a duplicate email" do
      create(:student, email: 'student@example.com', school: school)
      student.email = 'student@example.com'
      expect(student).not_to be_valid
      expect(student.errors[:email]).to include("has already been taken")
    end

    it "is not valid without first_name" do
      student.first_name = nil
      expect(student).not_to be_valid
      expect(student.errors[:first_name]).to include("can't be blank")
    end

    it "is not valid without last_name" do
      student.last_name = nil
      expect(student).not_to be_valid
      expect(student.errors[:last_name]).to include("can't be blank")
    end

    it "is not valid without type" do
      student.type = nil
      expect(student).not_to be_valid
      expect(student.errors[:type]).to include("can't be blank")
    end

    it "is not valid without a school" do
      student.school = nil
      expect(student).not_to be_valid
      expect(student.errors[:school]).to include("must be associated with a school")
    end

    describe "email format validation" do
      it "accepts valid email addresses" do
        valid_emails = [
          'student@example.com',
          'student.name@example.com',
          'student+tag@example.co.uk',
          'student123@example-domain.org'
        ]

        valid_emails.each do |email|
          student.email = email
          expect(student).to be_valid, "Expected #{email} to be valid"
        end
      end

      it "rejects invalid email addresses" do
        invalid_emails = [
          'invalid',
          '@example.com',
          'student@',
          'student@.com',
          'student@example',
          'student@example.',
          'student@example..com',
          'student@example.c',
          's@example.com' # local part too short
        ]

        invalid_emails.each do |email|
          student.email = email
          expect(student).not_to be_valid, "Expected #{email} to be invalid"
          expect(student.errors[:email]).to be_present
        end
      end

      it "rejects email with local part less than 2 characters" do
        student.email = 's@example.com'
        expect(student).not_to be_valid
        expect(student.errors[:email]).to include("local part must be at least 2 characters")
      end

      it "rejects email with invalid domain structure" do
        student.email = 'student@example'
        expect(student).not_to be_valid
        expect(student.errors[:email]).to include("domain must be properly formatted (e.g., example.com)")
      end

      it "rejects email with domain extension less than 2 characters" do
        student.email = 'student@example.c'
        expect(student).not_to be_valid
        expect(student.errors[:email]).to include("domain extension must be at least 2 characters")
      end
    end
  end

  describe "associations" do
    it "belongs to a school" do
      expect(student.school).to eq(school)
    end

    it "has many enrollments" do
      expect(student).to respond_to(:enrollments)
    end

    it "has many courses through enrollments" do
      expect(student).to respond_to(:courses)
    end

    it "has many purchases" do
      expect(student).to respond_to(:purchases)
    end

    it "has many term subscriptions" do
      expect(student).to respond_to(:term_subscriptions)
    end
  end

  describe "Devise modules" do
    it "includes database_authenticatable" do
      expect(Student.devise_modules).to include(:database_authenticatable)
    end

    it "includes registerable" do
      expect(Student.devise_modules).to include(:registerable)
    end

    it "includes recoverable" do
      expect(Student.devise_modules).to include(:recoverable)
    end

    it "includes rememberable" do
      expect(Student.devise_modules).to include(:rememberable)
    end

    it "includes validatable" do
      expect(Student.devise_modules).to include(:validatable)
    end
  end

  describe "role checking methods" do
    it "has student? method" do
      expect(student).to respond_to(:student?)
    end

    it "has admin? method" do
      expect(student).to respond_to(:admin?)
    end

    it "returns correct role values" do
      expect(student.student?).to be true
      expect(student.admin?).to be false
    end
  end

  describe "deletion validation" do
    let(:student) { create(:student, school: school) }

    context "when student has no associated records" do
      it "can be deleted" do
        student.reload
        expect { student.destroy }.to change(Student, :count).by(-1)
      end
    end

    # context "when student has enrollments" do
    #   before do
    #     term = create(:term, school: school)
    #     course = create(:course, school: school, term: term)
    #   end

    #   it "cannot be deleted" do
    #     student.reload
    #     expect { student.destroy }.not_to change(Student, :count)
    #     expect(student.errors[:base]).to include("Cannot delete student with enrollments")
    #   end
    # end

    context "when student has purchases" do
      before do
        term = create(:term, school: school)
        create(:purchase, student: student, purchasable: term)
      end

      it "cannot be deleted" do
        expect { student.destroy }.not_to change(Student, :count)
        expect(student.errors[:base]).to include("Cannot delete student with purchases")
      end
    end

    context "when student has term subscriptions" do
      before do
        term = create(:term, school: school)
        create(:term_subscription, student: student, term: term)
      end

      it "cannot be deleted" do
        expect { student.destroy }.not_to change(Student, :count)
        expect(student.errors[:base]).to include("Cannot delete student with term subscriptions")
      end
    end

    context "when student has multiple types of associated records" do
      before do
        term = create(:term, school: school)
        course = create(:course, school: school, term: term)
        create(:enrollment, student: student, course: course)
      end

      it "cannot be deleted and shows all relevant error messages" do
        expect { student.destroy }.not_to change(Student, :count)
        expect(student.errors[:base]).to include("Cannot delete student with enrollments")
      end
    end
  end

  describe "factory" do
    it "has a valid student factory" do
      expect(build(:student)).to be_valid
    end

    it "creates a student with correct type" do
      student = create(:student)
      expect(student.type).to eq('Student')
      expect(student).to be_a(Student)
    end

    it "associates with a school by default" do
      student = create(:student)
      expect(student.school).to be_present
      expect(student.school).to be_a(School)
    end
  end
end 