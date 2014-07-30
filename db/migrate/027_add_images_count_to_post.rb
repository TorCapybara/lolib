class AddImagesCountToPost < ActiveRecord::Migration
  def change
    add_column :posts, :images_count, :integer, :default => 0
  end
end
