# == Schema Information
#
# Table name: staff_members
#
#  id               :bigint           not null, primary key
#  bio              :text
#  display_order    :integer          default(0)
#  is_band_director :boolean          default(FALSE), not null
#  name             :string           not null
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  program_id       :bigint
#  school_id        :bigint           not null
#
# Indexes
#
#  index_staff_members_on_program_id  (program_id)
#  index_staff_members_on_school_id   (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (program_id => programs.id)
#  fk_rails_...  (school_id => schools.id)
#
require "test_helper"

class StaffMemberTest < ActiveSupport::TestCase
  test "ordered scope puts band director first and sorts by display order and name" do
    school = School.create!(name: "Test School")
    staff = StaffMember.create!(name: "Zed", school: school, display_order: 5)
    director = StaffMember.create!(name: "Alice", school: school, is_band_director: true, display_order: 1)
    another = StaffMember.create!(name: "Bob", school: school, display_order: 1)

    assert_equal [director, another, staff], StaffMember.ordered.to_a
  end
end
