class AddBoardThreadIdToImages < ActiveRecord::Migration
  def change
    add_column :images, :board_thread_id, :integer
  end
end
