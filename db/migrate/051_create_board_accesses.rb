class CreateBoardAccesses < ActiveRecord::Migration
  def change
    drop_table :name_spaces_roles

    create_table :board_accesses do |t|
      t.integer :role_id
      t.integer :name_space_id
      t.integer :flags, :integer, :null => false, :default => 0

      t.timestamps
    end
  end
end
