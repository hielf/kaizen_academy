require 'rails_helper'

RSpec.describe "Admin::Licenses", type: :request do
  let(:admin) { create(:admin) }
  let(:school) { create(:school) }
  let(:term) { create(:term, school: school) }

  before do
    sign_in admin
  end

  describe "GET /index" do
    it "returns http success" do
      get admin_school_term_licenses_path(school, term), as: :turbo_stream
      expect(response).to have_http_status(:success)
    end
  end
end 