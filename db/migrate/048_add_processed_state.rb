class AddProcessedState < ActiveRecord::Migration
  def change
    add_column :videos, :processed, :boolean, :null => false, :default => false
    add_column :images, :processed, :boolean, :null => false, :default => false

  end
end
