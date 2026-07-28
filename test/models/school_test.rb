# == Schema Information
#
# Table name: schools
#
#  id                        :bigint           not null, primary key
#  about                     :string
#  about_hero_image          :string
#  boosters_enabled          :boolean          default(FALSE), not null
#  calendar_url              :string
#  call_to_action            :string
#  city                      :string
#  contact_us                :string
#  default_image             :string
#  description               :string
#  director_email            :string(255)
#  director_name             :string(255)
#  director_phone            :string(255)
#  district                  :string
#  established               :date
#  fundraisers_enabled       :boolean          default(FALSE), not null
#  handbook_contract_form    :string
#  hero_title                :string(100)
#  home_page_image_urls      :string
#  name                      :string(100)      not null
#  percussion_director_email :string(255)
#  percussion_director_name  :string(255)
#  percussion_director_phone :string(255)
#  performance_absence_form  :string
#  photo_gallery_enabled     :boolean          default(FALSE), not null
#  rehearsal_absence_form    :string
#  staff_enabled             :boolean          default(FALSE), not null
#  state                     :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  district_id               :bigint
#
# Indexes
#
#  index_schools_on_district_id  (district_id)
#  index_schools_on_name         (name)
#
# Foreign Keys
#
#  fk_rails_...  (district_id => districts.id)
#
require "test_helper"

class SchoolTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
