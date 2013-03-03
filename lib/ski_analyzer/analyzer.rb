require 'gpx_utils/waypoints_importer'

module SkiAnalyzer
  class Analyzer
    def initialize(gpx_file, start = nil, finish = nil)
      @file = gpx_file

      @i = GpxUtils::TrackImporter.new
      @i.add_file(@file)

      @coords = @i.coords.clone

      # where you start sleeping
      @start = start
      @start = find_start if @start.nil?
      puts "Start - #{@start.inspect}"

      # where you start skiing
      @finish = finish
      @finish = find_finish if @finish.nil?
      puts "Finish - #{@finish.inspect}"

      #g = Geokit::LatLng.new(@coords.first[:lat], @coords.first[:lon])
      #puts g.inspect

      #@coords.each do |c|
      #  puts "#{c[:lat]},#{c[:lon]} #{c[:alt]}"
      #end
    end

    def find_start
      @coords.sort { |a, b| a[:alt] <=> b[:alt] }.first
    end

    def find_finish
      @coords.sort { |a, b| a[:alt] <=> b[:alt] }.last
    end
  end
end
