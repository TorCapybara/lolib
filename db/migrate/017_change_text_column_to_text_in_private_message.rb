class ChangeTextColumnToTextInPrivateMessage < ActiveRecord::Migration
  def change
    change_column :private_messages, :text, :text
  end
end
