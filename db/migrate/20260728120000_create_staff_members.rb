class CreateStaffMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :staff_members do |t|
      t.string :name, null: false
      t.string :title
      t.text :bio
      t.boolean :is_band_director, default: false, null: false
      t.integer :display_order, default: 0
      t.references :school, null: false, foreign_key: true
      t.references :program, foreign_key: true, null: true

      t.timestamps
    end
  end
end
