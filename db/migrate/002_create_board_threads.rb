class CreateBoardThreads < ActiveRecord::Migration
  def change
    create_table :board_threads do |t|
      t.string :title
      t.integer :views, :default => 0
      t.integer :user_id
      t.integer :name_space_id

      t.timestamps
    end
  end
end
