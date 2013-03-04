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

      calculate_speed
      process

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

    def calculate_speed
      (1...@coords.size).each do |i|
        ga = Geokit::LatLng.new(@coords[i-1][:lat], @coords[i-1][:lon])
        gb = Geokit::LatLng.new(@coords[i][:lat], @coords[i][:lon])
        d = ga.distance_from(gb, units: :kms)
        td = @coords[i][:time] - @coords[i-1][:time]

        @coords[i][:distance] = d * 1000.0
        @coords[i][:speed] = @coords[i][:distance] / td

        puts "D - #{@coords[i][:distance]} m | S - #{@coords[i][:speed]} m/s"
      end
    end

    def process
      # do not add coords not near start point
      j = nil
      @coords.each_with_index do |c, i|
        ga = Geokit::LatLng.new(@start[:lat], @start[:lon])
        gb = Geokit::LatLng.new(c[:lat], c[:lon])
        d = ga.distance_from(gb, units: :kms)
        if j.nil? and d < 0.1
          puts "Choosen #{i} waypoint as start, distance #{d}"
          j = i
        end
      end
      @coords = @coords[j..-1]

      # calculate distance to start and finish
      @coords.each do |c|
        gf = Geokit::LatLng.new(@finish[:lat], @finish[:lon])
        gs = Geokit::LatLng.new(@start[:lat], @start[:lon])
        g = Geokit::LatLng.new(c[:lat], c[:lon])

        df = g.distance_from(gf, units: :kms)
        ds = g.distance_from(gs, units: :kms)

        c[:d_start] = ds
        c[:d_finish] = df
      end

      # check if ascend/descend
      (1...@coords.size).each do |i|

      end



    end
  end
end
