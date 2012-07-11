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

      @line = Magick::Draw.new
      @line.stroke_antialias(@aa)
      @line.text_antialias(@aa)
      #@line.fill_opacity(0.0)
      @line.stroke(@color)
      @line.stroke_opacity(@opacity)
      @line.stroke_width(@width)

      #@line.stroke_linecap('square')
      #@line.stroke_linejoin('miter')
      ## @line.pointsize(options[:axis_font_size])
      #@line.font_family('helvetica')
      #@line.font_style(Magick::NormalStyle)
      #@line.text_align(Magick::LeftAlign)
    end

    # Create new (full) image
    def new_image(x, y)
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

    def save(filename)
      @line.draw(@image)
      @image.write(filename)
    end

    def to_png
      # TODO
    end

  end
end