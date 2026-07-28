class AddFeatureFlagsToSchools < ActiveRecord::Migration[7.0]
  def change
    add_column :schools, :staff_enabled, :boolean, default: false, null: false
    add_column :schools, :boosters_enabled, :boolean, default: false, null: false
    add_column :schools, :fundraisers_enabled, :boolean, default: false, null: false
    add_column :schools, :photo_gallery_enabled, :boolean, default: false, null: false
  end
end
