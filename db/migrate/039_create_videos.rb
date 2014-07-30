class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer :board_thread_id
      t.integer :user_id
      t.string :name
      t.string :video
      t.string :url
      t.integer :size
      t.string :sha1
      t.string :md5
      t.string :contact_sheet
      t.integer :length

      t.timestamps
    end
  end
end
