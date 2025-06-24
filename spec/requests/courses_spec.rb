require 'rails_helper'

RSpec.describe "Courses", type: :request do
  let(:school) { create(:school) }
  let(:term) { create(:term, school: school) }
  let(:course) { create(:course, term: term) }
  let(:student) { create(:student, school: school) }
  let!(:enrollment) { create(:enrollment, student: student, course: course) }

  before do
    sign_in student
  end

  describe "GET /show" do
    it "returns http success" do
      get course_path(course)
      expect(response).to have_http_status(:success)
    end
  end
end 