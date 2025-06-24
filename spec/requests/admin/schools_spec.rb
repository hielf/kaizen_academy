require 'rails_helper'

RSpec.describe "Admin::Schools", type: :request do
  let(:admin) { create(:admin) }

  before do
    # Sign in the admin user before each test
    sign_in admin
  end

  describe "GET /admin/schools" do
    it "renders the index template" do
      get admin_schools_path
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

  describe "GET /admin/schools/:id" do
    let(:school) { create(:school) }
    it "renders the show template" do
      get admin_school_path(school)
      expect(response).to be_successful
      expect(response).to render_template(:show)
    end
  end

  describe "GET /admin/schools/new" do
    it "renders the new template" do
      get new_admin_school_path
      expect(response).to be_successful
      expect(response).to render_template(:new)
    end
  end

  describe "POST /admin/schools" do
    context "with valid parameters" do
      let(:valid_params) { { school: { name: "New University" } } }

      it "creates a new school" do
        expect {
          post admin_schools_path, params: valid_params
        }.to change(School, :count).by(1)
      end

      it "redirects to the created school" do
        post admin_schools_path, params: valid_params
        expect(response).to redirect_to(admin_school_path(School.last))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { school: { name: "" } } }

      it "does not create a new school" do
        expect {
          post admin_schools_path, params: invalid_params
        }.not_to change(School, :count)
      end

      it "renders the new template with an unprocessable entity status" do
        post admin_schools_path, params: invalid_params
        expect(response).to have_http_status(422)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET /admin/schools/:id/edit" do
    let(:school) { create(:school) }
    it "renders the edit template" do
      get edit_admin_school_path(school)
      expect(response).to be_successful
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH /admin/schools/:id" do
    let(:school) { create(:school) }

    context "with valid parameters" do
      let(:valid_params) { { school: { name: "Updated University" } } }

      it "updates the requested school" do
        patch admin_school_path(school), params: valid_params
        school.reload
        expect(school.name).to eq("Updated University")
      end

      it "redirects to the school" do
        patch admin_school_path(school), params: valid_params
        expect(response).to redirect_to(admin_school_path(school))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { school: { name: "" } } }

      it "does not update the school" do
        patch admin_school_path(school), params: invalid_params
        school.reload
        expect(school.name).not_to eq("")
      end

      it "renders the edit template with an unprocessable entity status" do
        patch admin_school_path(school), params: invalid_params
        expect(response).to have_http_status(422)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE /admin/schools/:id" do
    let!(:school) { create(:school) }

    context "when the school has no dependencies" do
      it "destroys the requested school" do
        expect {
          delete admin_school_path(school)
        }.to change(School, :count).by(-1)
      end

      it "redirects to the schools list" do
        delete admin_school_path(school)
        expect(response).to redirect_to(admin_schools_path)
      end
    end

    context "when the school has dependencies" do
      before { create(:term, school: school) }

      it "does not destroy the school" do
        expect {
          delete admin_school_path(school)
        }.not_to change(School, :count)
      end

      it "redirects to the schools list with an alert" do
        delete admin_school_path(school)
        expect(response).to redirect_to(admin_schools_path)
        expect(flash[:alert]).to be_present
      end
    end
  end
end 