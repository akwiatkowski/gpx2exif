require 'rubygems'
require 'mini_exiftool'

$:.unshift(File.dirname(__FILE__))

module Gpx2exif
  class ExifEditor

    def initialize
      @images = Array.new
      @time_offset = 0
    end

    attr_reader :images
    attr_accessor :time_offset

    def read_file(path)
      i = {
        :path => path,
        :time => get_photo_time(path) + @time_offset
      }
      @images << i
      puts "Added file #{path}, time #{i[:time]}"
    end

    def get_photo_time(path)
      photo = MiniExiftool.new path
      photo['DateTimeOriginal']
    end

    def set_photo_coords(path, lat, lon, alt = 0.0)
      photo = MiniExiftool.new path
      photo['GPSLatitude'] = lat
      photo['GPSLongitude'] = lon
      photo['GPSAltitude'] = alt
      photo.save

      # exiftool -GPSMapDatum="WGS-84" -gps:GPSLatitude="34,57,57"
      # -gps:GPSLatitudeRef="N" -gps:GPSLongitude="83,17,59" -gps:GPSLongitudeRef="W"
      # -gps:GPSAltitudeRef="0" -GPSAltitude=1426 -gps:GPSMeasureMode=2 -City="RabunBald"
      # -State="North Carolina" -Country="USA" ~/Desktop/RabunBaldSummit_NC.jpg

    end

  end
end