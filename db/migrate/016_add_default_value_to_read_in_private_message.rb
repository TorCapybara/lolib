class AddDefaultValueToReadInPrivateMessage < ActiveRecord::Migration
  def change
    change_column :private_messages, :read, :boolean, :default => false
  end
end
