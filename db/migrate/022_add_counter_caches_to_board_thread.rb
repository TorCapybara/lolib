class AddCounterCachesToBoardThread < ActiveRecord::Migration
  def change
    add_column :board_threads, :images_count, :integer, :default => 0
    add_column :board_threads, :posts_count, :integer, :default => 0
  end
end
