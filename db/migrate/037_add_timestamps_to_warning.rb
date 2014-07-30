class AddTimestampsToWarning < ActiveRecord::Migration
  def change
    change_table(:warnings) do |t|
      t.timestamps
    end
  end
end
