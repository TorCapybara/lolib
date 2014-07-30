class ChangeIntegerOfCounterInStatistics < ActiveRecord::Migration
  def change
    change_column :statistics, :counter, :integer, :limit => 8
  end
end
