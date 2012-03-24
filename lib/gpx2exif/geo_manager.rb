require 'rubygems'

$:.unshift(File.dirname(__FILE__))

module Gpx2exif
  class GeoManager

    def initialize
      @ee = ExifEditor.new
      @gp = GpxParser.new
    end

    def add_gpx_file(path)
      @gp.add_file(path)
    end

    def add_image(path)
      @ee.read_file(path)
    end

    def match_up
      @ee.images.each do |i|
        puts "* searching for #{i[:path]}, time #{i[:time]}"
        i[:coord] = @gp.find_by_time(i[:time])
        if i[:coord].nil?
          puts " - not found"
        end
      end

    end

    # Save all coords
    def save!
      @ee.images.each do |i|
        if not i[:coord].nil?
          puts "! saving for #{i[:path]}"
          @ee.set_photo_coords_internal(i)
        end

      end
    end


  end
end