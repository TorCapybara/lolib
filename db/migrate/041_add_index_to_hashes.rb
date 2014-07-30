class AddIndexToHashes < ActiveRecord::Migration
  def change
    add_index :images, :sha1_digest
    add_index :images, :md5_digest
    add_index :images, :crc32
  end
end
