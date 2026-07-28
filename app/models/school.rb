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
class School < ApplicationRecord
  belongs_to :district, optional: true
  has_many :programs, dependent: :destroy
  has_many :boosters, dependent: :destroy
  has_many :galleries, dependent: :destroy
  has_many :staff_members, dependent: :destroy

  has_many_attached :pdf_uploads

  validate :pdf_upload_type

  def pdf_upload_type
    return unless pdf_uploads.attached?
    return unless pdf_uploads.last.id == nil  # only validate the last uploaded file

    errors.add(:pdf_upload, 'Must be a PDF file') unless pdf_uploads.last.content_type.in?(%w(application/pdf))
  end

  def to_s
    name
  end

  def location
    "#{city}, #{state}"
  end

  def images
    images ||= home_page_image_urls.split(",") if home_page_image_urls.present?
  end
end
