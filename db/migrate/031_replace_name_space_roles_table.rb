class ReplaceNameSpaceRolesTable < ActiveRecord::Migration
  def change
    drop_table :name_spaces_roles

    create_table :name_spaces_roles do |t|
      t.belongs_to :name_spaces
      t.belongs_to :roles
    end
  end
end
