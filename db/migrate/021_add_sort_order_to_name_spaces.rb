class AddSortOrderToNameSpaces < ActiveRecord::Migration
  def change
    add_column :name_spaces, :sort_order, :integer, :default => -1
  end
end
