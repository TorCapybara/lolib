class AddExifDataToImage < ActiveRecord::Migration
  def change
    add_column :images, :exif, :boolean
    add_column :images, :exif_created_at, :datetime
    add_column :images, :exif_camera, :string
    add_column :images, :exif_exposure, :string
    add_column :images, :exif_f_stop, :string
  end
end
