require 'rubygems'
require 'chunky_png'

$:.unshift(File.dirname(__FILE__))

# This renderer has some/a lot of features missing
module Gpx2png
  class ChunkyPngRenderer
    def initialize(_options = {})
      @options = _options || {}
      @_color = @options[:color] || '#FF0000'
      @color = ChunkyPNG::Color.from_hex(@_color)
    end

    attr_accessor :x, :y

    # Create new (full) image
    def new_image
      @image = ChunkyPNG::Image.new(
        @x,
        @y,
        ChunkyPNG::Color::WHITE
      )
    end

    def add_point_image(blob, x_offset, y_offset)
      # not implemented
    end

    # Add one tile to full image
    def add_tile(blob, x_offset, y_offset)
      tile_image = ChunkyPNG::Image.from_blob(blob)
      @image.compose!(
        tile_image,
        x_offset,
        y_offset
      )
    end

    def line(xa, ya, xb, yb)
      @image.line(
        xa, ya,
        xb, yb,
        @color
      )
    end

    def set_crop(x_min, x_max, y_min, y_max)
      # TODO
    end

    def crop
      # TODO
    end

    def save(filename)
      @image.save(filename)
    end

    def to_png
      # TODO
    end

  end
end