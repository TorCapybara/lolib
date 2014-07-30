class ChangeNamesInVideoToMatchImageModel < ActiveRecord::Migration
  def change
    remove_column :videos, :sha1
    add_column :videos, :sha1_digest, :string
    remove_column :videos, :md5
    add_column :videos, :md5_digest, :string
  end
end
