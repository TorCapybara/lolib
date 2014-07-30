class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.string :counter_type
      t.string :scope
      t.integer :counter, :default => 0

      t.timestamps
    end
  end
end
