require 'rails_helper'

RSpec.describe Admin::StudentsController, type: :controller do
  let(:admin) { create(:admin) }
  let(:school) { create(:school) }
  let(:student) { create(:student, school: school) }

  before do
    sign_in admin
  end

  describe "GET #index" do
    let!(:student1) { create(:student, school: school, email: "alice@example.com", first_name: "Alice", last_name: "Smith") }
    let!(:student2) { create(:student, school: school, email: "bob@example.com", first_name: "Bob", last_name: "Johnson") }
    let!(:student3) { create(:student, school: school, email: "charlie@example.com", first_name: "Charlie", last_name: "Brown") }

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assigns @students with all students" do
      get :index
      expect(assigns(:students)).to include(student1, student2, student3)
    end

    it "orders students by email" do
      get :index
      expect(assigns(:students).to_a).to eq([student1, student2, student3])
    end

    it "includes school associations" do
      get :index
      expect(assigns(:students).first.association(:school).loaded?).to be true
    end

    context "with name filter" do
      it "filters by email" do
        get :index, params: { name_filter: "alice" }
        expect(assigns(:students)).to include(student1)
        expect(assigns(:students)).not_to include(student2, student3)
      end

      it "filters by first name" do
        get :index, params: { name_filter: "Bob" }
        expect(assigns(:students)).to include(student2)
        expect(assigns(:students)).not_to include(student1, student3)
      end

      it "filters by last name" do
        get :index, params: { name_filter: "Brown" }
        expect(assigns(:students)).to include(student3)
        expect(assigns(:students)).not_to include(student1, student2)
      end

      it "filters case insensitive" do
        get :index, params: { name_filter: "ALICE" }
        expect(assigns(:students)).to include(student1)
      end

      it "filters with partial matches" do
        get :index, params: { name_filter: "al" }
        expect(assigns(:students)).to include(student1)
        expect(assigns(:students)).not_to include(student2, student3)
      end
    end

    context "with school filter" do
      let(:other_school) { create(:school, name: "Other School") }
      let!(:other_student) { create(:student, school: other_school, email: "other@example.com") }

      it "filters by school name" do
        get :index, params: { school_filter: "Other" }
        expect(assigns(:students)).to include(other_student)
        expect(assigns(:students)).not_to include(student1, student2, student3)
      end

      it "filters case insensitive" do
        get :index, params: { school_filter: "other" }
        expect(assigns(:students)).to include(other_student)
      end

      it "filters with partial matches" do
        get :index, params: { school_filter: "School" }
        expect(assigns(:students)).to include(other_student)
      end
    end

    context "with both filters" do
      let(:other_school) { create(:school, name: "Other School") }
      let!(:other_student) { create(:student, school: other_school, email: "other@example.com", first_name: "Alice") }

      it "applies both filters" do
        get :index, params: { name_filter: "Alice", school_filter: "Other" }
        expect(assigns(:students)).to include(other_student)
        expect(assigns(:students)).not_to include(student1, student2, student3)
      end
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: student.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns @student" do
      get :show, params: { id: student.id }
      expect(assigns(:student)).to eq(student)
    end

    context "with non-existent student" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get :show, params: { id: 99999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when student can be deleted" do
      let!(:student) { create(:student) }

      it "deletes the student" do
        expect {
          delete :destroy, params: { id: student.id }
        }.to change(Student, :count).by(-1)
      end

      it "redirects to students index with success notice" do
        delete :destroy, params: { id: student.id }
        expect(response).to redirect_to(admin_students_path)
        expect(flash[:notice]).to eq("Student was successfully deleted.")
      end
    end

    context "when student cannot be deleted" do
      before do
        term = create(:term, school: school)
        course = create(:course, school: school, term: term)
        create(:enrollment, student: student, course: course)
      end

      it "does not delete the student" do
        expect {
          delete :destroy, params: { id: student.id }
        }.not_to change(Student, :count)
      end

      it "redirects to student show with error message" do
        delete :destroy, params: { id: student.id }
        expect(response).to redirect_to(admin_student_path(student))
        expect(flash[:alert]).to include("Cannot delete student with enrollments")
      end
    end

    context "with non-existent student" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          delete :destroy, params: { id: 99999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "authentication" do
    context "when not signed in" do
      before { sign_out admin }

      it "redirects to sign in page for index" do
        get :index
        expect(response).to redirect_to(root_path)
      end

      it "redirects to sign in page for show" do
        get :show, params: { id: student.id }
        expect(response).to redirect_to(root_path)
      end

      it "redirects to sign in page for destroy" do
        delete :destroy, params: { id: student.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context "when signed in as student" do
      before { sign_in(student) }

      it "denies access to index" do
        get :index
        expect(response).to redirect_to(root_path)
      end

      it "denies access to show" do
        get :show, params: { id: student.id }
        expect(response).to redirect_to(root_path)
      end

      it "denies access to destroy" do
        delete :destroy, params: { id: student.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end 