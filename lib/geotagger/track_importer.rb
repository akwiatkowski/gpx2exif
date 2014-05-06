require 'rubygems'
require 'nokogiri'
require 'geokit'

$:.unshift(File.dirname(__FILE__))

# Simple parsing GPX file
module Geotagger
  class TrackImporter < GpxUtils::TrackImporter

    THRESHOLD = 5*60

    attr_accessor :verbose
    attr_accessor :debug

    # Only import valid coords
    def self.coord_valid?(lat, lon, elevation, time)
      return true if lat and lon and time
      return false
    end

    # Would be better to add this to GpxUtils::TrackImporter so it filters on import
    def filter_by(time_range)
      if time_range.length > 1
        @coords = @coords.select do |coord|
          coord[:time] &&
          coord[:time] >= time_range[0] &&
          coord[:time] <= time_range[1]
        end
      else
        puts "Cannot filter on invalid time range: #{time_range}"
      end
    end

    def determine_directions(index=0)
      if @coords.length > 1
        previous_point = nil
        @coords.each do |coord|
          point = Geokit::LatLng.new(coord[:lat], coord[:lon])
          if previous_point
            coord[:direction] = previous_point.heading_to(point)
          end
          previous_point = point
        end
        @coords[0][:direction] = @coords[1][:direction]
      end
    end

    def search_back(lt,index)
      puts "\tSearching backwards from index #{index}" if @debug
      while index > 0 && @coords[index][:time].localtime > lt
        index -= 1
      end
      puts "\tNew search index[#{index}]: #{@coords[index][:time].localtime}" if @debug
      index
    end

    def search_forward(lt,index)
      puts "\tSearching forwards from index #{index}" if @debug
      while index < (@coords.length-1) && @coords[index][:time].localtime < lt
        index += 1
      end
      search_back(lt,index)
    end

    def interpolate_between(a,b,time)
      lt = time.localtime
      ta = lt - a[:time].localtime
      tb = b[:time].localtime - lt
      if @debug
        puts "\tComparing times: #{time}"
        puts "\t\tPrev: #{a}"
        puts "\t\tNext: #{b}"
        puts "\t\t#{ta} after previous"
        puts "\t\t#{tb} before next"
      end
      if ta < 0
        if tb < 0
          puts "\tNo correlation for #{lt}" if @verbose
        elsif -ta < tb
          puts "\tClosest match: #{a}" if @verbose
          a
        else
          puts "\tClosest match: #{b}" if @verbose
          b
        end
      else
        if tb < 0
          if -tb < ta
            puts "\tClosest match: #{b}" if @verbose
            b
          else
            puts "\tClosest match: #{a}" if @verbose
            a
          end
        else
          if @debug
            puts "\tinterpolating between #{a[:time]} and #{b[:time]}"
            puts "\tweighted averaging: weights a=#{tb}, b=#{ta}"
          end
          lat = (a[:lat] * tb + b[:lat] * ta) / (ta + tb)
          lon = (a[:lon] * tb + b[:lon] * ta) / (ta + tb)
          direction = (a[:direction] * tb + b[:direction] * ta) / (ta + tb)
          coord = {:lat => lat, :lon => lon, :time => time, :direction => direction}
          puts "\tweighted average: #{coord}" if @verbose
          coord
        end
      end
    end

    def interpolate_by_time(time)
      lt = time.localtime
      @previous_search_index ||= 0
      plt = @coords[@previous_search_index][:time].localtime
      puts "\tStarting correlation search for '#{lt}' from previous time: #{plt}" if @verbose
      if plt == lt
        @coords[@previous_search_index]
      elsif plt > lt
        @previous_search_index = search_back(lt,@previous_search_index)
        interpolate_between(@coords[@previous_search_index],@coords[@previous_search_index+1],time)
      else
        @previous_search_index = search_forward(lt,@previous_search_index)
        interpolate_between(@coords[@previous_search_index],@coords[@previous_search_index+1],time)
      end
    end

    def find_by_time(time)
      selected_coords = @coords.select do |c|
        (c[:time].localtime - time.localtime).abs < THRESHOLD
      end
      selected_coords = selected_coords.sort do |a, b|
        (a[:time].localtime - time.localtime).abs <=> (b[:time].localtime - time.localtime).abs
      end
      if @verbose
        puts " - found #{selected_coords.size} coords within #{THRESHOLD}s from image time"
        if selected_coords.size > 0
          puts " - best is #{selected_coords.first[:time].localtime}, time offset #{selected_coords.first[:time].localtime - time.localtime}"
          puts " - lat #{selected_coords.first[:lat]} lon #{selected_coords.first[:lon]}"
        end
        puts " - interpolation: #{interpolate_by_time(time)}"
      end

      return selected_coords.first
    end

    def self.make_label(point, image=nil)
      "#{point[:time].strftime('%H:%M:%S')}: (#{point[:lat]}, #{point[:lon]})#{image.nil? ? '' : image[:path]}"
    end

    def add_image_marker(image)
      @images ||= []
      @images << image
    end

    def auto_marker(distance_threshold = 0.02)
      distance_threshold = 0.02 unless(distance_threshold.to_f > 0.001)
      puts "Track starts: #{self.class.make_label self.coords[0]}"
      puts "Track ends: #{self.class.make_label self.coords[-1]}"

      coordset = self.coords.map do |coord|
        image = (@images||[]).select {|i| i[:coord] == coord}[0]
        {coord: coord, image: image}
      end

      prev_point = nil
      coordset.each_with_index do |co,index|
        coord = co[:coord]
        image = co[:image]
        puts "Labeling coord:#{coord} with image: #{image}" if image
        point = Geokit::LatLng.new(coord[:lat], coord[:lon])
        if prev_point.nil? || (distance = point.distance_from(prev_point, units: :kms) > distance_threshold)
          label = self.class.make_label coord, image
          prev_point = point
          yield({lat: coord[:lat], lon: coord[:lon], label: label})
        end
      end
      
    end

  end
end
