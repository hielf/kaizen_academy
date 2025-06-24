require 'rails_helper'

RSpec.describe "Admin::Courses", type: :request do
  let(:admin) { create(:admin) }
  let(:school) { create(:school) }
  let(:term) { create(:term, school: school) }

  before do
    sign_in admin
  end

  describe "GET /index" do
    it "returns http success" do
      get admin_school_term_courses_path(school, term)
      expect(response).to have_http_status(:success)
    end
  end
end 