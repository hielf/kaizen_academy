require 'rails_helper'

RSpec.describe Users::PasswordsController, type: :controller do
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
    context "with valid email" do
      let!(:user) { create(:student, email: "test@example.com") }

      it "sends password reset instructions" do
        post :create, params: { user: { email: user.email } }
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end

      it "redirects to sign in page with notice" do
        post :create, params: { user: { email: user.email } }
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:notice]).to be_present
      end
    end
  end

  describe "GET #edit" do
    let(:user) { create(:student) }
    let(:token) { user.send_reset_password_instructions }

    it "returns http success" do
      get :edit, params: { reset_password_token: token }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT #update" do
    let(:user) { create(:student) }
    let(:token) { user.send_reset_password_instructions }

    context "with valid parameters" do
      it "updates the password" do
        put :update, params: { user: { reset_password_token: token, password: "newpassword", password_confirmation: "newpassword" } }
        user.reload
        expect(user.valid_password?("newpassword")).to be_truthy
      end
    end
  end
end 