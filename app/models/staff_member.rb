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
class StaffMember < ApplicationRecord
  belongs_to :school
  belongs_to :program, optional: true

  has_one_attached :photo

  validates :name, presence: true

  scope :ordered, -> { order(is_band_director: :desc, display_order: :asc, name: :asc) }
end
