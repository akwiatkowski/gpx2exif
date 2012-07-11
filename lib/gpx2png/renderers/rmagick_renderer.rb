require 'rubygems'
require 'RMagick'

$:.unshift(File.dirname(__FILE__))

module Gpx2png
  class RmagickRenderer
    def initialize(_options = { })
      @options = _options || {}
      @color = @options[:color] || '#FF0000'
      @width = @options[:width] || 3
      @aa = @options[:aa] == true
      @opacity = @options[:opacity] || 1.0
      @licence_string = "Map data OpenStreetMap (CC-by-SA 2.0)"

      @line = Magick::Draw.new
      @line.stroke_antialias(@aa)
      @line.stroke(@color)
      @line.stroke_opacity(@opacity)
      @line.stroke_width(@width)

      @licence_text = Magick::Draw.new
      @licence_text.text_antialias(@aa)
      @licence_text.font_family('helvetica')
      @licence_text.font_style(Magick::NormalStyle)
      @licence_text.text_align(Magick::RightAlign)
      @licence_text.pointsize(10)
    end

    # Create new (full) image
    def new_image(x, y)
      @x = x
      @y = y
      @image = Magick::Image.new(
        x,
        y
      )
    end

    # Add one tile to full image
    def add_tile(blob, x_offset, y_offset)
      tile_image = Magick::Image.from_blob(blob)[0]
      @image = @image.composite(
        tile_image,
        x_offset,
        y_offset,
        Magick::OverCompositeOp
      )
    end

    def line(xa, ya, xb, yb)
      @line.line(
        xa, ya,
        xb, yb
      )
    end

    def render
      @line.draw(@image)
      @licence_text.text(@x - 10, @y - 10, @licence_string)
      @licence_text.draw(@image)
    end

    def save(filename)
      render
      @image.write(filename)
    end

    def to_png
      # TODO
    end

  end
end