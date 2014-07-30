class AddFlagsToBoardThread < ActiveRecord::Migration
  def change
    add_column :board_threads, :flags, :integer, :null => false, :default => 0
  end
end
