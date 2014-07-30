class ChangeIntegerLengthInUser < ActiveRecord::Migration
  def change
    change_column :users, :byte_download, :integer, :limit => 8
  end
end
