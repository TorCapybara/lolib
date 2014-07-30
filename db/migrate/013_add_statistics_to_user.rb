class AddStatisticsToUser < ActiveRecord::Migration
  def change
    add_column :users, :image_download, :integer, :default => 0
    add_column :users, :byte_download, :integer, :default => 0
    add_column :users, :last_online, :datetime
  end
end
