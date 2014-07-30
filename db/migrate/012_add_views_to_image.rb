class AddViewsToImage < ActiveRecord::Migration
  def change
    add_column :images, :views, :integer, :default => 0
  end
end
