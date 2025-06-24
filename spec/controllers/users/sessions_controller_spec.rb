require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with valid credentials" do
      let!(:user) { create(:student, email: "test@example.com", password: "password123") }

      it "signs in the user" do
        post :create, params: { user: { email: "test@example.com", password: "password123" } }
        expect(controller.current_user).to eq(user)
      end

      it "redirects to the root path" do
        post :create, params: { user: { email: "test@example.com", password: "password123" } }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid credentials" do
      it "does not sign in the user" do
        post :create, params: { user: { email: "test@example.com", password: "wrongpassword" } }
        expect(controller.current_user).to be_nil
      end

      it "renders the new template" do
        post :create, params: { user: { email: "test@example.com", password: "wrongpassword" } }
        expect(response).to render_template(:new)
      end

      it "sets flash alert" do
        post :create, params: { user: { email: "test@example.com", password: "wrongpassword" } }
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:user) { create(:student) }

    before do
      sign_in user
    end

    it "signs out the user" do
      delete :destroy
      expect(controller.current_user).to be_nil
    end

    it "redirects to root path" do
      delete :destroy
      expect(response).to redirect_to(root_path)
    end
  end
end 