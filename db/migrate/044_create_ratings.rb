class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :user_id
      t.integer :board_thread_id
      t.integer :rating_type_id
      t.integer :rating

      t.timestamps
    end

    add_index :ratings, :user_id
    add_index :ratings, :board_thread_id
    add_index :ratings, :rating_type_id
  end
end
