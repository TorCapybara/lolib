class AddFlagsToNameSpaces < ActiveRecord::Migration
  def change
    add_column :name_spaces, :flags, :integer, :null => false, :default => 0
  end
end
