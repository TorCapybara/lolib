class CreateNameSpaces < ActiveRecord::Migration
  def change
    create_table :name_spaces do |t|
      t.string :name
      t.integer :parent_id

      t.timestamps
    end
  end
end
