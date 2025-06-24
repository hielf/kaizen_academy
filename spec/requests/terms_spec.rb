require 'rails_helper'

RSpec.describe "Terms", type: :request do
  let(:school) { create(:school) }
  let(:term) { create(:term, school: school) }
  let(:student) { create(:student, school: school) }

  before do
    sign_in student
  end

  describe "GET /show" do
    it "returns http success" do
      get term_path(term)
      expect(response).to have_http_status(:success)
    end
  end
end 