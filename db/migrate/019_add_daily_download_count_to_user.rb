class AddDailyDownloadCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :today_views, :integer, :default => 0
    add_column :users, :last_image_view, :date
    remove_column :users, :last_login
  end
end
