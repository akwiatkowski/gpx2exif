require 'rubygems'
require 'gpx_utils'
require 'geotagger/exif_editor'
require 'geotagger/track_importer'

$:.unshift(File.dirname(__FILE__))

module Geotagger
  class Geotagger

    attr_reader :options, :ti

    def initialize(options = {})
      @verbose = options[:verbose]
      @ee = ExifEditor.new options
      @ti = TrackImporter.new
      @ti.verbose = @verbose
      @ti.debug = options[:debug]
      @ee.global_time_offset = options[:time_offset].to_i
    end

    # Add all GPX and images with
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

    def add_pattern_files(prefix, num, suffix)
      Dir.glob("#{prefix}#{'?'*num}#{suffix}", File::FNM_CASEFOLD).each do |f|
        if f =~ /#{prefix}(\d{#{num}})#{suffix}/
          add_image(f, $1.to_i)
        else
          puts "Invalid image, does not match pattern /#{prefix}(\d{#{num}})#{suffix}/: #{f}"
        end
      end
    end

    def add_pattern(pattern)
      f = pattern.split(/\%/)
      if f.length > 1
        prefix=f[0]
        if f[1] =~ /^(\d+)d(.*)/
          num = $1.to_i
          suffix = $2
          add_pattern_files(prefix, num, suffix, time_offset)
        else
          puts "Unrecognized pattern: Expecting decimals and 'd' after '%' in #{pattern}"
        end
      else
        puts "Unrecognized pattern: Expecting '%#d' in #{pattern}"
      end
    end

    def add_gpx_file(path)
      @ti.add_file(path)
    end

    def add_image(path, time_offset = 0)
      @ee.read_file(path, time_offset)
    end

    def fix_times
      @ee.fix_times
    end

    def match_up
      @ti.determine_directions
      @ee.images.each do |i|
        puts "Searching for #{i}" if @verbose
        i[:coord] = @ti.interpolate_by_time(i[:fixed_time])
        if i[:coord].nil?
          puts "\tNot found" if @verbose
        else
           puts "\tGeolocated: #{i[:coord]}" if @verbose
           @ti.add_image_marker(i)
        end
      end

    end

    # Save all coords
    def save!
      @ee.images.each do |i|
        if not i[:coord].nil?
          puts "! saving for #{i[:path]}" if @verbose
          i.save!
        end

      end
    end

    def simulate
      to_process = @ee.images.select { |i| not i[:coord].nil? }
      puts "Result: to update #{to_process.size} from #{@ee.images.size}" if @verbose
    end

  end
end
