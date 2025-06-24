require 'rails_helper'

RSpec.describe "Admin::Terms", type: :request do
  let(:admin) { create(:admin) }
  let(:school) { create(:school) }

  before do
    sign_in admin
  end

  describe "GET /index" do
    it "returns http success" do
      get admin_school_terms_path(school)
      expect(response).to have_http_status(:success)
    end
  end
end 