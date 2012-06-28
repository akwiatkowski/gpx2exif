require 'rubygems'
require 'chunky_png'
require 'net/http'
require "uri"


$:.unshift(File.dirname(__FILE__))

module Gpx2png
  class Gpx2png

    TILE_WIDTH = 256
    TILE_HEIGHT = 256

    def initialize
      @coords = Array.new
      @zoom = 8
      @color = ChunkyPNG::Color::rgba(256, 0, 0, 128)
    end

    def add(lat, lon)
      @coords << { lat: lat, lon: lon }
    end

    attr_accessor :zoom, :color

    def dev
      zoom = 15
      @coords.collect { |c|
        {
          url: self.class.url(zoom, [c[:lat], c[:lon]]),
          tile: self.class.convert(zoom, [c[:lat], c[:lon]]),
          return: self.class.reverse_convert(zoom,
                                             self.class.convert(zoom, [c[:lat], c[:lon]])
          ),
          point: self.class.point_on_image(zoom, [c[:lat], c[:lon]])
        }
      }
    end

    def to_png
      nil
    end

    # http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#X_and_Y
    def self.convert(zoom, coord)
      lat_deg, lon_deg = coord
      lat_rad = deg2rad(lat_deg)
      x = (((lon_deg + 180) / 360) * (2 ** zoom)).floor
      y = ((1 - Math.log(Math.tan(lat_rad) + 1 / Math.cos(lat_rad)) / Math::PI) /2 * (2 ** zoom)).floor

      return [x, y]
    end

    def self.url_convert(zoom, coord, server = 'b.')
      x, y = convert(zoom, coord)
      url(zoom, [x, y], server)
    end

    def self.url(zoom, coord, server = 'b.')
      x, y = coord
      url = "http://#{server}tile.openstreetmap.org\/#{zoom}\/#{x}\/#{y}.png"
      return url
    end

    # top-left corner
    def self.reverse_convert(zoom, coord)
      x, y = coord
      n = 2 ** zoom
      lon_deg = x.to_f / n.to_f * 360.0 - 180.0
      lat_deg = rad2deg(Math.atan(Math.sinh(Math::PI * (1.to_f - 2.to_f * y.to_f / n.to_f))))
      return [lat_deg, lon_deg]
    end

    # return where you should put point on tile
    def self.point_on_image(zoom, geo_coord)
      osm_tile_coord = convert(zoom, geo_coord)
      top_left_corner = reverse_convert(zoom, osm_tile_coord)
      bottom_right_corner = reverse_convert(zoom, [
        osm_tile_coord[0] + 1, osm_tile_coord[1] + 1
      ])

      # some line y = ax + b math

      x_geo = geo_coord[1]
      # offset
      x_offset = x_geo - top_left_corner[1]
      # scale
      x_distance = (bottom_right_corner[1] - top_left_corner[1])
      x = (TILE_WIDTH.to_f * (x_offset / x_distance)).round

      y_geo = geo_coord[0]
      # offset
      y_offset = y_geo - top_left_corner[0]
      # scale
      y_distance = (bottom_right_corner[0] - top_left_corner[0])
      y = (TILE_HEIGHT.to_f * (y_offset / y_distance)).round

      return { osm_title_coord: osm_tile_coord, pixel_offset: [x, y] }
    end


    attr_reader :lat_min, :lat_max, :lon_min, :lon_max
    attr_reader :tile_x_distance, :tile_y_distance

    def download_and_join_tiles
      @lat_min = @coords.collect { |c| c[:lat] }.min
      @lat_max = @coords.collect { |c| c[:lat] }.max
      @lon_min = @coords.collect { |c| c[:lon] }.min
      @lon_max = @coords.collect { |c| c[:lon] }.max

      @border_tiles = [
        self.class.convert(@zoom, [@lat_min, @lon_min]),
        self.class.convert(@zoom, [@lat_max, @lon_max])
      ]

      @tile_x_range = (@border_tiles[0][0])..(@border_tiles[1][0])
      @tile_y_range = (@border_tiles[1][1])..(@border_tiles[0][1])

      # new image
      @full_image_x = (1 + @tile_x_range.max - @tile_x_range.min) * TILE_WIDTH
      @full_image_y = (1 + @tile_y_range.max - @tile_y_range.min) * TILE_HEIGHT
      puts @full_image_x, @full_image_y
      @full_image = ChunkyPNG::Image.new(
        @full_image_x,
        @full_image_y,
        ChunkyPNG::Color::WHITE
      )

      # {:x, :y, :blob}
      @images = Array.new

      @tile_x_range.each do |x|
        @tile_y_range.each do |y|
          url = self.class.url(@zoom, [x,y])

          # blob time
          uri = URI.parse(url)
          response = Net::HTTP.get_response(uri)
          blob = response.body
          image = ChunkyPNG::Image.from_blob(blob)

          @images << {
            url: url,
            image: image,
            x: x,
            y: y
          }

          # compose image
          x_offset = (@tile_x_range.min - x) * TILE_WIDTH
          y_offset = (@tile_y_range.min - y) * TILE_HEIGHT
          puts x_offset, y_offset
          @full_image.compose!(image, x_offset, y_offset)
          
          puts "#{x} #{y}"
        end
      end

      # sweet, image is joined

      # add some coords to the map
      (1...@coords.size).each do |i|
        lat_from = @coords[i-1][:lat]
        lon_from = @coords[i-1][:lon]

        lat_from = @coords[i-1][:lat]
        lon_from = @coords[i-1][:lon]
      end
      #@image.line(x, 0, x, height, ChunkyPNG::Color.from_hex(_options[:color]))

      @full_image.save('sample.png')


    end

    def expand_map
      # TODO expand min and max ranges
    end


    # Some math stuff
    def self.rad2deg(rad)
      return rad * 180.0 / Math::PI
    end

    def self.deg2rad(deg)
      return deg * Math::PI / 180.0
    end


  end
end