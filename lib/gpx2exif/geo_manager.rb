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
        puts i
      end
    end


  end
end