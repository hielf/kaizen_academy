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

  describe "POST /create" do
    let(:valid_card_params) do
      {
        credit_card_payment: {
          card_number: "4242424242424242",
          expiry_date: "12/25",
          cvv: "123"
        },
        signed_info: Rails.application.message_verifier('purchasable-item').generate({ type: 'Course', id: course.id })
      }
    end

    it "creates a purchase and links it to credit card payment" do
      expect {
        post payments_path, params: valid_card_params
      }.to change { Purchase.count }.by(1)
        .and change { CreditCardPayment.count }.by(1)

      purchase = Purchase.last
      credit_card_payment = CreditCardPayment.last

      expect(purchase.credit_card_payment).to eq(credit_card_payment)
      expect(credit_card_payment.purchase).to eq(purchase)
      expect(purchase.student).to eq(student)
      expect(purchase.purchasable).to eq(course)
    end
  end
end 