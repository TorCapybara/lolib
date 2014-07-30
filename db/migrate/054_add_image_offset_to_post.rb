class AddImageOffsetToPost < ActiveRecord::Migration
  def change
    add_column :posts, :image_offset, :integer
  end
end
