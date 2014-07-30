class CreatePingBacks < ActiveRecord::Migration
  def change
    create_table :ping_backs do |t|
      t.string :referer
      t.integer :counter, :default => 0
      t.boolean :visible, :default => false

      t.timestamps
    end
  end
end
