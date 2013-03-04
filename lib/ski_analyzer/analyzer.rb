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

        @coords[i][:distance] = d
        @coords[i][:speed] = (@coords[i][:distance] * 1000.0) / td

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
      j = 0
      t = :up
      (1...@coords.size).each do |i|
        if t == :up
          if @coords[i][:d_finish] < 0.1 and @coords[i-1][:d_finish] < @coords[i][:d_finish]
            t = :down
            j += 1
            puts "Type change #{i} - #{t} - #{j}"
          end
        elsif t == :down
          if @coords[i][:d_start] < 0.1 and @coords[i-1][:d_start] < @coords[i][:d_start]
            t = :up
            j += 1
            puts "Type change #{i} - #{t} - #{j}"
          end
        end

        @coords[i][:type] = t
        @coords[i][:round] = j
      end

      # some computing
      # distance quant calculation, from "finish"
      q = 0.05 # quant
      gf = Geokit::LatLng.new(@finish[:lat], @finish[:lon])
      gs = Geokit::LatLng.new(@start[:lat], @start[:lon])
      round_distance = gf.distance_from(gs, units: :kms)
      quant_count = round_distance / q
      quant_count = quant_count.ceil
      q = round_distance / quant_count

      puts "Distance quant #{q}, count #{quant_count}"

      result = Array.new
      (0..j).each do |round|
        # round loop
        (0..quant_count).each do |qc|
          # quant loop

          d_from = q * qc
          d_to = (q + 1) * qc
          coords = @coords.select { |c| c[:round] == round and c[:d_finish] >= d_from and c[:d_finish] < d_to }
          puts "Found coords #{coords.size} for round #{round} and quant #{qc}"

          h = Hash.new
          h[:round] = round
          begin
            h[:type] = coords.first[:type]
          rescue
          end

          sq = 0
          h[:speed] = 0.0
          coords.each do |coord|
            _s = coord[:speed]
            if a
              h[:speed] = 0.0
            end

          end

          puts h.inspect

        end
      end


    end
  end
end
