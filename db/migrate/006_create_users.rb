class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :avatar
      t.string :description
      t.string :likes
      t.string :tor_chat
      t.string :password_digest
      t.integer :role_id
      t.integer :mentor_id
      t.integer :thread_count, :default => 0
      t.integer :post_count, :default => 0
      t.integer :image_count, :default => 0
      t.integer :last_login

      t.timestamps
    end
  end
end
