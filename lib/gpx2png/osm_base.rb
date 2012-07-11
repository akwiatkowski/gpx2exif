require 'rubygems'
require 'gpx2png/base'
require 'net/http'
require "uri"

$:.unshift(File.dirname(__FILE__))

module Gpx2png
  class OsmBase < Base
    TILE_WIDTH = 256
    TILE_HEIGHT = 256

    # http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#X_and_Y
    # Convert latlon deg to OSM tile coords
    def self.convert(zoom, coord)
      lat_deg, lon_deg = coord
      lat_rad = deg2rad(lat_deg)
      x = (((lon_deg + 180) / 360) * (2 ** zoom)).floor
      y = ((1 - Math.log(Math.tan(lat_rad) + 1 / Math.cos(lat_rad)) / Math::PI) /2 * (2 ** zoom)).floor

      return [x, y]
    end

    # Convert latlon deg to OSM tile url
    # TODO add algorithm to choose from diff. servers
    def self.url_convert(zoom, coord, server = 'b.')
      x, y = convert(zoom, coord)
      url(zoom, [x, y], server)
    end

    # Convert OSM tile coords to url
    def self.url(zoom, coord, server = 'b.')
      x, y = coord
      url = "http://#{server}tile.openstreetmap.org\/#{zoom}\/#{x}\/#{y}.png"
      return url
    end

    # Convert OSM tile coords to latlon deg in top-left corner
    def self.reverse_convert(zoom, coord)
      x, y = coord
      n = 2 ** zoom
      lon_deg = x.to_f / n.to_f * 360.0 - 180.0
      lat_deg = rad2deg(Math.atan(Math.sinh(Math::PI * (1.to_f - 2.to_f * y.to_f / n.to_f))))
      return [lat_deg, lon_deg]
    end

    # Convert latlon deg coords to image point (x,y) and OSM tile coord
    # return where you should put point on tile
    def self.point_on_image(zoom, geo_coord)
      osm_tile_coord = convert(zoom, geo_coord)
      top_left_corner = reverse_convert(zoom, osm_tile_coord)
      bottom_right_corner = reverse_convert(zoom, [
        osm_tile_coord[0] + 1, osm_tile_coord[1] + 1
      ])

      # some line math: y = ax + b

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

    def initial_calculations
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
      @r.x = @full_image_x
      @r.y = @full_image_y

      calculate_for_crop
    end

    attr_reader :lat_min, :lat_max, :lon_min, :lon_max
    attr_reader :tile_x_distance, :tile_y_distance
    # points for cropping
    attr_reader :bitmap_point_x_max, :bitmap_point_x_min, :bitmap_point_y_max, :bitmap_point_y_min

    def download_and_join_tiles

      puts "Output image dimension #{@full_image_x}x#{@full_image_y}" if @verbose
      @r.new_image

      # {:x, :y, :blob}
      @images = Array.new

      @tile_x_range.each do |x|
        @tile_y_range.each do |y|
          url = self.class.url(@zoom, [x, y])

          # blob time
          uri = URI.parse(url)
          response = Net::HTTP.get_response(uri)
          blob = response.body

          @r.add_tile(
            blob,
            (x - @tile_x_range.min) * TILE_WIDTH,
            (y - @tile_y_range.min) * TILE_HEIGHT
          )

          @images << {
            url: url,
            x: x,
            y: y
          }

          puts "processed #{x - @tile_x_range.min}x#{y - @tile_y_range.min} (max #{@tile_x_range.max - @tile_x_range.min}x#{@tile_y_range.max - @tile_y_range.min})" if @verbose
        end
      end

      # sweet, image is joined

      # min/max points used for cropping
      @bitmap_point_x_max = (@full_image_x / 2).round
      @bitmap_point_x_min = (@full_image_x / 2).round
      @bitmap_point_y_max = (@full_image_y / 2).round
      @bitmap_point_y_min = (@full_image_y / 2).round

      # add some coords to the map
      (1...@coords.size).each do |i|
        lat_from = @coords[i-1][:lat]
        lon_from = @coords[i-1][:lon]

        lat_to = @coords[i][:lat]
        lon_to = @coords[i][:lon]

        point_from = self.class.point_on_image(@zoom, [lat_from, lon_from])
        point_to = self.class.point_on_image(@zoom, [lat_to, lon_to])
        # { osm_title_coord: osm_tile_coord, pixel_offset: [x, y] }

        # first point
        bitmap_xa = (point_from[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + point_from[:pixel_offset][0]
        bitmap_ya = (point_from[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + point_from[:pixel_offset][1]
        bitmap_xb = (point_to[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + point_to[:pixel_offset][0]
        bitmap_yb = (point_to[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + point_to[:pixel_offset][1]

        @r.line(
          bitmap_xa, bitmap_ya,
          bitmap_xb, bitmap_yb
        )

        # updating points for cropping
        # lazy way
        #@bitmap_point_x_max = bitmap_xa if bitmap_xa > @bitmap_point_x_max
        #@bitmap_point_x_max = bitmap_xb if bitmap_xb > @bitmap_point_x_max
        #@bitmap_point_x_min = bitmap_xa if bitmap_xa < @bitmap_point_x_min
        #@bitmap_point_x_min = bitmap_xb if bitmap_xb < @bitmap_point_x_min
        #
        #@bitmap_point_y_max = bitmap_xa if bitmap_xa > @bitmap_point_x_max
        #@bitmap_point_y_max = bitmap_xb if bitmap_xb > @bitmap_point_x_max
        #@bitmap_point_y_min = bitmap_xa if bitmap_xa < @bitmap_point_x_min
        #@bitmap_point_y_min = bitmap_xb if bitmap_xb < @bitmap_point_x_min

      end

      calculate_for_crop
    end

    # Calculate some numbers for cropping operation
    def calculate_for_crop
      point_min = self.class.point_on_image(@zoom, [@lat_min, @lon_min])
      point_max = self.class.point_on_image(@zoom, [@lat_max, @lon_max])
      @bitmap_point_x_min = (point_min[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + point_min[:pixel_offset][0]
      @bitmap_point_x_max = (point_max[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + point_max[:pixel_offset][0]
      @bitmap_point_y_max = (point_min[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + point_min[:pixel_offset][1]
      @bitmap_point_y_min = (point_max[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + point_max[:pixel_offset][1]

      @r.set_crop(@bitmap_point_x_min, @bitmap_point_x_max, @bitmap_point_y_min, @bitmap_point_y_max)
    end

    def expand_map
      # TODO expand min and max ranges
    end

  end
end
