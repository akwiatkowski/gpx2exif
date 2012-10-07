require 'rubygems'
require 'gpx2png/base'
require 'net/http'
require "uri"

$:.unshift(File.dirname(__FILE__))

module Gpx2png
  class OsmBase < Base
    TILE_WIDTH = 256
    TILE_HEIGHT = 256

    # if true it will not download tiles
    attr_accessor :simulate_download

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

    # Lazy calc proper zoom for drawing
    def self.calc_zoom(lat_min, lat_max, lon_min, lon_max, width, height)
      # because I'm lazy! :] and math is not my best side

      last_zoom = 2
      (5..18).each do |zoom|
        # calculate drawing tile size and pixel size
        tile_min = point_on_absolute_image(zoom, [lat_min, lon_min])
        tile_max = point_on_absolute_image(zoom, [lat_max, lon_max])
        current_pixel_x_distance = tile_max[0] - tile_min[0]
        current_pixel_y_distance = tile_min[1] - tile_max[1]
        if current_pixel_x_distance > width or current_pixel_y_distance > height
          return last_zoom
        end
        last_zoom = zoom
      end
      return 18
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

    # Useful for calculating distance on output image
    # It is not position on output image because we don't know tile coords
    # For upper-left tile
    def self.point_on_absolute_image(zoom, geo_coord)
      _p = point_on_image(zoom, geo_coord)
      _x = _p[:osm_title_coord][0] * TILE_WIDTH + _p[:pixel_offset][0]
      _y = _p[:osm_title_coord][1] * TILE_WIDTH + _p[:pixel_offset][1]
      return [_x, _y]
    end

    # Create image with fixed size
    def fixed_size(_width, _height)
      @fixed_width = _width
      @fixed_height = _height
    end

    def initial_calculations
      @lat_min = @coords.collect { |c| c[:lat] }.min
      @lat_max = @coords.collect { |c| c[:lat] }.max
      @lon_min = @coords.collect { |c| c[:lon] }.min
      @lon_max = @coords.collect { |c| c[:lon] }.max

      # auto zoom must be here
      # drawing must fit into fixed resolution
      # map must be bigger than fixed resolution
      if @fixed_width and @fixed_height
        @new_zoom = self.class.calc_zoom(
          @lat_min, @lat_max,
          @lon_min, @lon_max,
          @fixed_width, @fixed_height
        )
        puts "Calculated new zoom #{@new_zoom} (was #{@zoom})" if @verbose
        @zoom = @new_zoom
      end

      @border_tiles = [
        self.class.convert(@zoom, [@lat_min, @lon_min]),
        self.class.convert(@zoom, [@lat_max, @lon_max])
      ]

      @tile_x_range = (@border_tiles[0][0])..(@border_tiles[1][0])
      @tile_y_range = (@border_tiles[1][1])..(@border_tiles[0][1])

      # enlarging ranges to fill up map area
      # both sizes are enlarged
      # = ( ( (preferred size - real size) / tile width ) / 2 ).ceil
      if @fixed_width and @fixed_height
        x_axis_expand_count = ((@fixed_width - (1 + @tile_x_range.max - @tile_x_range.min) * TILE_WIDTH).to_f / (TILE_WIDTH.to_f * 2.0)).ceil
        y_axis_expand_count = ((@fixed_height - (1 + @tile_y_range.max - @tile_y_range.min) * TILE_HEIGHT).to_f / (TILE_HEIGHT.to_f * 2.0)).ceil
        puts "Expanding X tiles from both sides #{x_axis_expand_count}" if @verbose
        puts "Expanding Y tiles from both sides #{y_axis_expand_count}" if @verbose
        @tile_x_range = ((@tile_x_range.min - x_axis_expand_count)..(@tile_x_range.max + x_axis_expand_count))
        @tile_y_range = ((@tile_y_range.min - y_axis_expand_count)..(@tile_y_range.max + y_axis_expand_count))
      end

      # new/full image size
      @full_image_x = (1 + @tile_x_range.max - @tile_x_range.min) * TILE_WIDTH
      @full_image_y = (1 + @tile_y_range.max - @tile_y_range.min) * TILE_HEIGHT
      @r.x = @full_image_x
      @r.y = @full_image_y

      if @fixed_width and @fixed_height
        calculate_for_crop_with_auto_zoom
      else
        calculate_for_crop
      end
    end

    # Calculate zoom level
    def auto_zoom_for(x = 0, y = 0)
      # TODO
    end

    attr_reader :lat_min, :lat_max, :lon_min, :lon_max
    attr_reader :tile_x_distance, :tile_y_distance
    # points for cropping
    attr_reader :bitmap_point_x_max, :bitmap_point_x_min, :bitmap_point_y_max, :bitmap_point_y_min

    # Do everything
    def download_and_join_tiles
      puts "Output image dimension #{@full_image_x}x#{@full_image_y}" if @verbose
      @r.new_image

      # {:x, :y, :blob}
      @images = Array.new


      @tile_x_range.each do |x|
        @tile_y_range.each do |y|
          url = self.class.url(@zoom, [x, y])

          # blob time
          unless @simulate_download
            uri = URI.parse(url)
            response = Net::HTTP.get_response(uri)
            blob = response.body
          else
            blob = @r.blank_tile(TILE_WIDTH, TILE_HEIGHT, x+y)
          end

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
      end

      # add points
      @markers.each do |point|
        lat = point[:lat]
        lon = point[:lon]

        p = self.class.point_on_image(@zoom, [lat, lon])
        bitmap_x = (p[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + p[:pixel_offset][0]
        bitmap_y = (p[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + p[:pixel_offset][1]

        point[:x] = bitmap_x
        point[:y] = bitmap_y

        @r.markers << point
      end
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

    # Calculate some numbers for cropping operation with autozoom
    def calculate_for_crop_with_auto_zoom
      point_min = self.class.point_on_image(@zoom, [@lat_min, @lon_min])
      point_max = self.class.point_on_image(@zoom, [@lat_max, @lon_max])
      @bitmap_point_x_min = (point_min[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + point_min[:pixel_offset][0]
      @bitmap_point_x_max = (point_max[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + point_max[:pixel_offset][0]
      @bitmap_point_y_max = (point_min[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + point_min[:pixel_offset][1]
      @bitmap_point_y_min = (point_max[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + point_max[:pixel_offset][1]

      bitmap_x_center = (@bitmap_point_x_min + @bitmap_point_x_max) / 2
      bitmap_y_center = (@bitmap_point_y_min + @bitmap_point_y_max) / 2

      @r.set_crop_fixed(bitmap_x_center, bitmap_y_center, @fixed_width, @fixed_height)
    end

    def expand_map
      # TODO expand min and max ranges
    end

    def self.licence_string
      "Map data OpenStreetMap (CC-by-SA 2.0)"
    end

  end
end
