require 'rubygems'
require 'nokogiri'

$:.unshift(File.dirname(__FILE__))

# Simple parsing GPX file
module Geotagger
  class TrackImporter < GpxUtils::TrackImporter

    THRESHOLD = 5*60

    attr_accessor :verbose

    # Only import valid coords
    def self.coord_valid?(lat, lon, elevation, time)
      return true if lat and lon and time
      return false
    end

    def find_by_time(time)
      selected_coords = @coords.select { |c| (c[:time].localtime - time.localtime).abs < THRESHOLD }
      selected_coords = selected_coords.sort { |a, b| (a[:time].localtime - time.localtime).abs <=> (b[:time].localtime - time.localtime).abs }
      puts " - found #{selected_coords.size} coords within #{THRESHOLD}s from image time" if @verbose
      if selected_coords.size > 0
        puts " - best is #{selected_coords.first[:time].localtime}, time offset #{selected_coords.first[:time].localtime - time.localtime}" if @verbose
        puts " - lat #{selected_coords.first[:lat]} lon #{selected_coords.first[:lon]}" if @verbose
      end

      return selected_coords.first
    end

  end
end