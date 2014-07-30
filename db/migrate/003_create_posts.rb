class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :board_thread_id
      t.integer :user_id
      t.integer :parent_id
      t.text :text

      t.timestamps
    end
  end
end
