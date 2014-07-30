class CreateNameSpacesRoles < ActiveRecord::Migration
  def change
    create_table :name_spaces_roles do |t|
      t.belongs_to :assembly
      t.belongs_to :part
    end
  end
end
