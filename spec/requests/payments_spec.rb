require 'rails_helper'

RSpec.describe "Payments", type: :request do
  let(:student) { create(:student) }
  let(:course) { create(:course) }

  before do
    sign_in student
    # Use the prepare action to set the session
    post "/payments/prepare", params: { signed_info: Rails.application.message_verifier('purchasable-item').generate({ type: 'Course', id: course.id }) }
  end

  describe "GET /new" do
    it "returns http success" do
      get new_payment_path
      expect(response).to have_http_status(:success)
    end
  end
end 