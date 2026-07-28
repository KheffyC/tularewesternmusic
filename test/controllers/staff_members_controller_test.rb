require "test_helper"

class StaffMembersControllerTest < ActionDispatch::IntegrationTest
  test "returns 404 when staff feature is disabled" do
    school = School.create!(name: "Test School")
    get staff_members_path

    assert_response :not_found
  end

  test "renders staff page when feature is enabled" do
    school = School.create!(name: "Test School", staff_enabled: true)
    StaffMember.create!(name: "Alice", school: school)

    get staff_members_path

    assert_response :success
  end
end
