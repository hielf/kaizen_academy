require 'rails_helper'

RSpec.describe User, type: :model do
  # Shared examples for basic user attributes and validations
  shared_examples_for "a user with base validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:type) }
  end

  # --- User (Base Model) Tests ---
  describe "User as base model" do
    let(:user) { create(:user) } # Using FactoryBot, ensure it's set up (see notes below)

    it_behaves_like "a user with base validations"

    it "is valid with a valid email and password" do
      expect(build(:user)).to be_valid
    end

    it "is not valid without an email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is not valid with a duplicate email" do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it "sets a default type of 'Student'" do
      user = User.new(email: 'new@example.com', password: 'password', password_confirmation: 'password')
      expect(user.type).to eq('Student')
    end

    describe "#after_sign_in_path_for" do
      it "redirects Admin to admin dashboard" do
        admin_user = build(:admin)
        expect(admin_user.after_sign_in_path_for(admin_user)).to eq("/admin/dashboard") # Replace with actual admin dashboard path
      end

      it "redirects Student to student dashboard" do
        student_user = build(:student)
        expect(student_user.after_sign_in_path_for(student_user)).to eq("/student/dashboard") # Replace with actual student dashboard path
      end

      it "redirects other types to Devise default" do
        # Create a generic user that isn't Admin or Student if you have other types
        # For now, just show the fallback behavior
        generic_user = build(:user) # A User instance whose type isn't explicitly 'Student' or 'Admin' in this context
        allow(generic_user).to receive(:is_a?).and_return(false) # Simulate not being Admin or Student
        expect(generic_user.after_sign_in_path_for(generic_user)).to eq("/") # Devise default root path
      end
    end
  end

  # --- Student Model Tests (STI) ---
  describe "Student model" do
    let(:school) { create(:school) } # Requires School factory
    let(:student) { create(:student, school: school) }

    it_behaves_like "a user with base validations"

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

    it { should belong_to(:school).optional(true) } # Test association
    it { should have_many(:enrollments).with_foreign_key(:user_id) } # Test STI foreign_key
    it { should have_many(:purchases).with_foreign_key(:user_id) }
    it { should have_many(:term_subscriptions).with_foreign_key(:user_id) }

    it "is valid with a school" do
      expect(build(:student, school: school)).to be_valid
    end

    it "is not valid without a school" do
      student_without_school = build(:student, school: nil)
      expect(student_without_school).not_to be_valid
      expect(student_without_school.errors[:school]).to include("must be associated with a school")
    end
  end

  # --- Admin Model Tests (STI) ---
  describe "Admin model" do
    let(:admin) { create(:admin) }

    it_behaves_like "a user with base validations"

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

    # Explicitly test that it does not belong to a school, or that school is optional
    it "does not require a school association (platform-wide)" do
      expect(build(:admin, school: nil)).to be_valid # Based on `t.references :school, optional: true`
    end
  end
end