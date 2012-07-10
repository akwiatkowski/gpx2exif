require 'rubygems'
require 'mini_exiftool'

$:.unshift(File.dirname(__FILE__))

module Geotagger
  class ExifEditor

    def initialize
      @images = Array.new
      @global_time_offset = 0
    end

    attr_reader :images
    attr_accessor :global_time_offset

    def read_file(path, time_offset = 0)
      i = {
        :path => path,
        :time => get_photo_time(path) + time_offset + @global_time_offset
      }
      @images << i
      puts "Added file #{path}, time #{i[:time]}"
    end

    def get_photo_time(path)
      photo = MiniExiftool.new path
      photo['DateTimeOriginal']
    end

    def set_photo_coords_internal(im)
      set_photo_coords(im[:path], im[:coord][:lat], im[:coord][:lon], im[:coord][:alt])
    end

    def set_photo_coords(path, lat, lon, alt = 0.0)
      photo = MiniExiftool.new path

      # http://en.wikipedia.org/wiki/Geotagging#JPEG_photos

      photo['GPSVersionID'] = '2 2 0 0'

      photo['GPSLatitude'] = lat
      photo['GPSLongitude'] = lon

      lat_ref = "N"
      lon_ref = "E"
      lat_ref = "S" if lat < 0.0
      lon_ref = "W" if lon < 0.0

      photo['GPSLatitudeRef'] = lat_ref
      photo['GPSLongitudeRef'] = lon_ref

      photo['GPSAltitude'] = alt
      photo.save

      photo2 = MiniExiftool.new path
      puts " - coord saved lat #{photo2['GPSLatitude']} lon #{photo2['GPSLongitude']}"

      # exiftool -GPSMapDatum="WGS-84" -gps:GPSLatitude="34,57,57"
      # -gps:GPSLatitudeRef="N" -gps:GPSLongitude="83,17,59" -gps:GPSLongitudeRef="W"
      # -gps:GPSAltitudeRef="0" -GPSAltitude=1426 -gps:GPSMeasureMode=2 -City="RabunBald"
      # -State="North Carolina" -Country="USA" ~/Desktop/RabunBaldSummit_NC.jpg

    end

  end
end
