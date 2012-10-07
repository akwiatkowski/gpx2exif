require 'rubygems'
require 'RMagick'
require 'gpx2png/assets/sample_marker'

$:.unshift(File.dirname(__FILE__))

module Gpx2png
  class RmagickRenderer
    def initialize(_options = { })
      @options = _options || { }
      @color = @options[:color] || '#FF0000'
      @width = @options[:width] || 3
      @aa = @options[:aa] == true
      @opacity = @options[:opacity] || 1.0
      @crop_margin = @options[:crop_margin] || 50
      @crop_enabled = @options[:crop_enabled] == true

      @line = Magick::Draw.new
      @line.stroke_antialias(@aa)
      @line.stroke(@color)
      @line.stroke_opacity(@opacity)
      @line.stroke_width(@width)

      @text = Magick::Draw.new
      @text.text_antialias(@aa)
      @text.font_family('helvetica')
      @text.font_style(Magick::NormalStyle)
      @text.text_align(Magick::RightAlign)
      @text.pointsize(12)


      @licence_text = Magick::Draw.new
      @licence_text.text_antialias(@aa)
      @licence_text.font_family('helvetica')
      @licence_text.font_style(Magick::NormalStyle)
      @licence_text.text_align(Magick::RightAlign)
      @licence_text.pointsize(12)

      @poi_images = Array.new
    end

    attr_accessor :x, :y
    attr_accessor :licence_string
    attr_accessor :poi_images

    # Create new (full) image
    def new_image
      @image = Magick::Image.new(
        @x,
        @y
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

    # Setup crop image using CSS padding style data
    def set_crop(x_min, x_max, y_min, y_max)
      # puts @x, @y, @crop_margin, x_min, x_max, y_min, y_max

      @crop_t = y_min - @crop_margin
      @crop_r = (@x - x_max) - @crop_margin
      @crop_b = (@y - y_max) - @crop_margin
      @crop_l = x_min - @crop_margin

      @crop_t = 0 if @crop_t < 0
      @crop_r = 0 if @crop_r < 0
      @crop_b = 0 if @crop_b < 0
      @crop_l = 0 if @crop_l < 0
    end

    # Setup crop for autozoom/fixed size
    def set_crop_fixed(x_center, y_center, width, height)
      @crop_margin = 0
      @crop_enabled = true

      set_crop(
        x_center - (width / 2),
        x_center + (width / 2),
        y_center - (height / 2),
        y_center + (height / 2)
      )
    end

    # Setup crop image using CSS padding style data
    def crop!
      return unless @crop_enabled

      @new_x = @x - @crop_r.to_i - @crop_l.to_i
      @new_y = @y - @crop_b.to_i - @crop_t.to_i
      @image = @image.crop(@crop_l.to_i, @crop_t.to_i, @new_x, @new_y, true)
      # changing image size
      @x = @new_x
      @y = @new_y
    end

    # Render only marker images, and perform some calculations
    def render_markers
      @poi_images.each do |p|
        # using custom marker
        _blob = p[:blob]
        # or default
        _blob = SampleMarker::BLOB if _blob.nil?

        img_tile = Magick::Image.from_blob(_blob)[0]
        p[:x_after_crop] = p[:x] - @crop_l.to_i
        p[:y_after_crop] = p[:y] - @crop_t.to_i
        p[:x_center] = p[:x_after_crop] - img_tile.columns / 2
        p[:y_center] = p[:y_after_crop] - img_tile.rows / 2
        p[:x_next_to_image] = p[:x_after_crop] + img_tile.columns

        @image = @image.composite(
          img_tile,
          p[:x_center],
          p[:y_center],
          Magick::OverCompositeOp
        )
      end
    end

    # Render nice looking labels
    def render_marker_labels
      @poi_images.each do |p|
        @text.text(p[:x_next_to_image], p[:y_after_crop], p[:label].to_s + " ")
      end
      @text.draw(@image)
    end

    def render
      @line.draw(@image)

      # crop after drawing lines, before drawing "legend"
      crop!

      # "static" elements
      @licence_text.text(@x - 10, @y - 10, @licence_string)
      @licence_text.draw(@image)

      # draw point images
      render_markers
      render_marker_labels
    end

    def save(filename)
      render
      @image.write(filename)
    end

    def to_png
      render
      @image.format = 'PNG'
      @image.to_blob
    end

    def blank_tile(width, height, index = 0)
      _image = Magick::Image.new(
        width,
        height
      ) do |i|
        _color = "#dddddd"
        _color = "#eeeeee" if index % 2 == 0
        i.background_color = _color
      end
      _image.format = 'PNG'
      _image.to_blob
    end

  end
end