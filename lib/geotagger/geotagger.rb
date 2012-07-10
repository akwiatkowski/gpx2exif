require 'rubygems'
require 'gpx_utils'
require 'geotagger/exif_editor'
require 'geotagger/track_importer'

$:.unshift(File.dirname(__FILE__))

module Geotagger
  class Geotagger

    def initialize
      @ee = ExifEditor.new
      #@ti = Geotagger::TrackImporter.new
      @ti = TrackImporter.new
    end

    def add_all_files(time_offset = 0)
      # add all GPX
      Dir.glob("**/*.GPX", File::FNM_CASEFOLD).each do |f|
        add_gpx_file(f)
      end

      # add all GPX
      Dir.glob("**/*.JPG", File::FNM_CASEFOLD).each do |f|
        add_image(f, time_offset)
      end
      Dir.glob("**/*.JPEG", File::FNM_CASEFOLD).each do |f|
        add_image(f, time_offset)
      end
    end

    def add_gpx_file(path)
      @ti.add_file(path)
    end

    def add_image(path, time_offset = 0)
      @ee.read_file(path, time_offset)
    end

    def match_up
      @ee.images.each do |i|
        puts "* searching for #{i[:path]}, time #{i[:time]}"
        i[:coord] = @ti.find_by_time(i[:time])
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

    def simulate
      to_process = @ee.images.select { |i| not i[:coord].nil? }
      puts "Result: to update #{to_process.size} from #{@ee.images.size}"
    end

  end
end