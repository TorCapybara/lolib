class ReplaceNameSpaceRolesTable2 < ActiveRecord::Migration
  def change
    drop_table :name_spaces_roles

    create_table :name_spaces_roles do |t|
      t.belongs_to :name_space
      t.belongs_to :role
    end
  end
end
