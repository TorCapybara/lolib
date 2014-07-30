class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :post_id
      t.integer :user_id
      t.string :name
      t.string :image
      t.string :md5_digest
      t.string :sha1_digest

      t.timestamps
    end
  end
end
