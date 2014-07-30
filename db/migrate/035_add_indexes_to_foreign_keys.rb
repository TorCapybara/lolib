class AddIndexesToForeignKeys < ActiveRecord::Migration
  def change
    add_index :name_spaces, :parent_id
    add_index :name_spaces, :sort_order

    add_index :board_threads, :user_id
    add_index :board_threads, :name_space_id

    add_index :posts, :user_id
    add_index :posts, :board_thread_id
    add_index :posts, :parent_id

    add_index :images, :post_id
    add_index :images, :board_thread_id
    add_index :images, :user_id

    add_index :users, :role_id
    add_index :users, :mentor_id

    add_index :private_messages, :sender_id
    add_index :private_messages, :receiver_id
    add_index :private_messages, :reply_id

    add_index :wiki_revisions, :user_id
    add_index :wiki_revisions, :wiki_id
  end
end
