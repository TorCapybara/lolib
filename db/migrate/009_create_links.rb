class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :uri
      t.string :name
      t.string :description
      t.boolean :last_check, :default => false
      t.float :uptime, :default => 0.0
      t.integer :views, :default => 0

      t.timestamps
    end
  end
end
