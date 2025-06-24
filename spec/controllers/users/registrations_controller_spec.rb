require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end

    it "sets @schools for the form" do
      school1 = create(:school, name: "School A", status: "active")
      school2 = create(:school, name: "School B", status: "active")
      create(:school, name: "School C", status: "inactive")
      get :new
      expect(assigns(:schools)).to eq([school1, school2])
    end

    it "orders schools by name" do
      school2 = create(:school, name: "School B")
      school1 = create(:school, name: "School A")
      get :new
      expect(assigns(:schools)).to eq([school1, school2])
    end
  end

  describe "POST #create" do
    let(:school) { create(:school, status: "active") }
    let(:valid_params) do
      {
        user: {
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          last_name: "Doe",
          school_id: school.id
        }
      }
    end

    context "with valid parameters" do
      it "creates a new student user" do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)
          .and change(Student, :count).by(1)
      end

      it "sets the user type to 'Student'" do
        post :create, params: valid_params
        
        user = User.last
        expect(user.type).to eq("Student")
        expect(user).to be_a(Student)
      end

      it "associates the user with the selected school" do
        post :create, params: valid_params
        
        user = User.last
        expect(user.school).to eq(school)
      end

      it "sets the user attributes correctly" do
        post :create, params: valid_params
        
        user = User.last
        expect(user.email).to eq("test@example.com")
        expect(user.first_name).to eq("John")
        expect(user.last_name).to eq("Doe")
      end

      it "redirects to the after sign up path" do
        post :create, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          user: {
            email: "invalid-email",
            password: "short",
            password_confirmation: "different",
            first_name: "",
            last_name: "",
            school_id: school.id
          }
        }
      end

      it "does not create a user" do
        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)
      end

      it "sets @schools for the form" do
        post :create, params: invalid_params
        
        expect(assigns(:schools)).to be_present
      end

      it "renders the new template" do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end
    end

    context "with missing school" do
      let(:params_without_school) do
        {
          user: {
            email: "test@example.com",
            password: "password123",
            password_confirmation: "password123",
            first_name: "John",
            last_name: "Doe",
            school_id: nil
          }
        }
      end

      it "does not create a user" do
        expect {
          post :create, params: params_without_school
        }.not_to change(User, :count)
      end

      it "renders the new template" do
        post :create, params: params_without_school
        expect(response).to render_template(:new)
      end
    end

    context "with non-existent school" do
      let(:params_with_invalid_school) do
        {
          user: {
            email: "test@example.com",
            password: "password123",
            password_confirmation: "password123",
            first_name: "John",
            last_name: "Doe",
            school_id: 99999
          }
        }
      end

      it "does not create a user" do
        expect {
          post :create, params: params_with_invalid_school
        }.not_to change(User, :count)
      end
    end
  end
end 