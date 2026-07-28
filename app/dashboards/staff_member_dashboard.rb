require "administrate/base_dashboard"

class StaffMemberDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    school: Field::BelongsTo,
    program: Field::BelongsTo.with_options(include_blank: true),
    name: Field::String,
    title: Field::String,
    bio: Field::Text,
    is_band_director: Field::Boolean,
    display_order: Field::Number,
    photo: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    school
    name
    title
    is_band_director
    display_order
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    school
    program
    name
    title
    bio
    is_band_director
    display_order
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    school
    name
    title
    bio
    is_band_director
    display_order
    photo
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(staff_member)
    staff_member.name
  end
end
