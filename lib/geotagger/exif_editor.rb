require 'rubygems'
require 'mini_exiftool'

$:.unshift(File.dirname(__FILE__))

module Geotagger

  # Wrapper class for path to image and the EXIF data read (and written)
  # to the image.
  class Image

    attr_reader :editor, :photo, :attr

    def initialize(editor, path, time_offset = 0)
      @editor = editor
      @photo = MiniExiftool.new path
      @attr = {
       :path => path,
       :time => (time = @photo['DateTimeOriginal']) && (time + time_offset + editor.global_time_offset)
      }
    end

    def path
      self[:path]
    end

    def time
      self[:time]
    end

    def [](key)
      @attr[key]
    end

    def []=(key,value)
      @attr[key] = value
    end

    def get_photo_time(offset=0)
      (time = photo['DateTimeOriginal']) && (time + offset)
    end

    def save!
      # http://en.wikipedia.org/wiki/Geotagging#JPEG_photos

      photo['ProcessingSoftware'] = 'gpx2exif'

      photo['GPSVersionID'] = '2 2 0 0'
      photo['DateTimeOriginal'] = self.time

      photo['GPSLatitude'] = @attr[:coord][:lat]
      photo['GPSLongitude'] = @attr[:coord][:lon]

      lat_ref = (@attr[:coord][:lat] < 0.0) ? "S" : "N"
      lon_ref = (@attr[:coord][:lon] < 0.0) ? "W" : "E"

      photo['GPSLatitudeRef'] = lat_ref
      photo['GPSLongitudeRef'] = lon_ref

      photo['GPSAltitude'] = @attr[:coord][:alt]
      photo['Orientation'] = 1	# 1 means normal upright landscape mode
      photo['GPSImgDirectionRef'] = 'T'	# T=true north (as opposed to M=magnetic)
      photo['GPSImgDirection'] = @attr[:coord][:direction]	# calculated in TrackImporter
      photo['GPSMapDatum'] = 'WGS-84'	# We assume all GPS data is WGS-84

      (editor.options[:exif_tags]||{}).each do |key,value|
        photo[key] = value
      end

      unless photo.save
        puts "Failed to save exif data to '#{path}': #{photo.errors.inspect}"
      end

      photo2 = MiniExiftool.new path
      puts " - coord saved lat #{photo2['GPSLatitude']} lon #{photo2['GPSLongitude']}" if editor.verbose

      # exiftool -GPSMapDatum="WGS-84" -gps:GPSLatitude="34,57,57"
      # -gps:GPSLatitudeRef="N" -gps:GPSLongitude="83,17,59" -gps:GPSLongitudeRef="W"
      # -gps:GPSAltitudeRef="0" -GPSAltitude=1426 -gps:GPSMeasureMode=2 -City="RabunBald"
      # -State="North Carolina" -Country="USA" ~/Desktop/RabunBaldSummit_NC.jpg
    end

    def to_s
      "Image[#{path}] at '#{time}'"
    end

  end

  class ExifEditor

    attr_reader :options, :verbose

    def initialize(options = {})
      @options = options
      @images = []
      @image_map = {}
      @global_time_offset = 0
      @verbose = options[:verbose]
    end

    attr_reader :images
    attr_accessor :global_time_offset

    def fix_times
      start_time = options[:start_time] && DateTime.parse(options[:start_time]) || DateTime.now
      puts "Start: #{start_time}"
      @images.each_with_index do |image,index|
        if image[:time].nil?
          timestamp = start_time + ((options[:time_gap] || 1000).to_i * index) / (1000.0 * 24 * 60 * 60)
          image[:time] = timestamp.to_time
        end
        puts "#{index}: #{image.attr.inspect}"
      end
    end

    def read_file(path, time_offset = 0)
      image = Image.new(self,path,time_offset)
      @images << image
      @image_map[path] = image
      puts "Added #{image}" if @verbose
      image
    end

    def get_photo_time(path)
      image = @image_map[path] || read_file(path)
      image.photo['DateTimeOriginal']
    end

  end
end
