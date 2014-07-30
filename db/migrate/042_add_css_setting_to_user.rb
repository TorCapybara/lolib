class AddCssSettingToUser < ActiveRecord::Migration
  def change
    add_column :users, :css, :integer, :null => false, :default => 0
  end
end
