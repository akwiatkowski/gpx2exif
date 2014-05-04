require 'rubygems'
require 'nokogiri'
require 'geokit'

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
      while index >= 0 && @coords[index][:time].localtime > lt
        index -= 1
      end
      index
    end

    def search_forward(lt,index)
      while index < @coords.length && @coords[index][:time].localtime < lt
        index += 1
      end
      index
    end

    def interpolate_between(a,b,time)
      lt = time.localtime
      ta = lt - a[:time].localtime
      tb = b[:time].localtime - lt
      if ta < 0
        if tb < 0
          puts "No correlation for #{lt}"
        else
          puts " - Closest match: #{b}"
          b
        end
      else
        if tb < 0
          puts " - Closest match: #{a}"
          a
        else
          puts " - interpolating between #{a[:time]} and #{b[:time]}"
          puts " - weighted averaging: weights a=#{tb}, b=#{ta}"
          lat = (a[:lat] * tb + b[:lat] * ta) / (ta + tb)
          lon = (a[:lon] * tb + b[:lon] * ta) / (ta + tb)
          direction = (a[:direction] * tb + b[:direction] * ta) / (ta + tb)
          coord = {:lat => lat, :lon => lon, :time => time, :direction => direction}
          puts " - weighted average: #{coord}"
          coord
        end
      end
    end

    def interpolate_by_time(time)
      lt = time.localtime
      @previous_search_index ||= 0
      if @coords[@previous_search_index][:time].localtime == lt
        @coords[@previous_search_index]
      elsif @coords[@previous_search_index][:time].localtime > lt
        @previous_search_index = search_back(lt,@previous_search_index)
        interpolate_between(@coords[@previous_search_index],@coords[@previous_search_index+1],time)
      else
        @previous_search_index = search_forward(lt,@previous_search_index)
        interpolate_between(@coords[@previous_search_index-1],@coords[@previous_search_index],time)
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

    def auto_marker
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
        if prev_point.nil? || (distance = point.distance_from(prev_point, units: :kms) > 0.02)
          label = self.class.make_label coord, image
          prev_point = point
          yield({lat: coord[:lat], lon: coord[:lon], label: label})
        end
      end
      
    end

  end
end
