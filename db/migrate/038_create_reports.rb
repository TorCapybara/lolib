class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :post_id
      t.integer :reporter_id
      t.text :message
      t.boolean :handled

      t.timestamps
    end
  end
end
