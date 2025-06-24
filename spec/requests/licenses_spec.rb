require 'rails_helper'

RSpec.describe "Licenses", type: :request do
  let(:student) { create(:student) }
  let(:term) { create(:term) }
  let!(:license) { create(:license, term: term) }

  before do
    sign_in student
  end

  describe "POST /redeem" do
    it "returns http success" do
      post redeem_license_path, params: { license_code: license.code, term_id: term.id }, as: :turbo_stream
      expect(response).to have_http_status(:success)
    end
  end
end 