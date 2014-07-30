class UpdateVideoMetaInfo < ActiveRecord::Migration
  def change
    remove_column :videos, :url
    remove_column :videos, :contact_sheet

    add_column :videos, :duration, :float, :null => false, :default => 0.0
    add_column :videos, :bit_rate, :integer, :null => false, :default => 0
    add_column :videos, :video_stream, :string
    add_column :videos, :video_codec, :string
    add_column :videos, :colorspace , :string
    add_column :videos, :width, :integer, :null => false, :default => 0
    add_column :videos, :height, :integer, :null => false, :default => 0
    add_column :videos, :frame_rate, :float, :null => false, :default => 0.0
    add_column :videos, :audio_stream, :string
    add_column :videos, :audio_codec, :string
    add_column :videos, :sample_rate, :integer, :null => false, :default => 0
    add_column :videos, :audio_channels, :integer, :null => false, :default => 0
  end
end
