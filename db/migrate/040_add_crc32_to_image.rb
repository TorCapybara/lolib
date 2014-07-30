class AddCrc32ToImage < ActiveRecord::Migration
  def change
    add_column :images, :crc32, :string
  end
end
