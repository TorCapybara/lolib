class AddMoreIndexesToKeys < ActiveRecord::Migration
  def change
    add_index :board_accesses, :name_space_id
    add_index :board_accesses, :role_id
    remove_column :board_accesses, :integer

    add_index :invitations, :mentor_id
    add_index :invitations, :user_id

    add_index :referers, :user_id

    add_index :reports, :reporter_id
    add_index :reports, :post_id
    drop_table :roles_tokens

    add_index :users, :last_online

    add_index :videos, :sha1_digest
    add_index :videos, :md5_digest
    add_index :videos, :board_thread_id
    add_index :videos, :user_id

    add_index :warnings, :user_id
    add_index :warnings, :moderator_id

    add_index :wiki_revisions, :revision
  end
end
