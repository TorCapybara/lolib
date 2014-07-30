class ChangeNameOfColumnsInUserTable < ActiveRecord::Migration
  def change
    rename_column :users, :post_count, :posts_count
    rename_column :users, :image_count, :images_count
  end
end
