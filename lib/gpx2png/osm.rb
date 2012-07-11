require 'rubygems'
require 'gpx2png/osm_base'

$:.unshift(File.dirname(__FILE__))

module Gpx2png
  class Osm < OsmBase

    DEFAULT_RENDERER = :chunky
    attr_accessor :renderer

    def initialize
      super
      @renderer ||= :chunky
      @r = nil
    end

    def to_png(filename)
      setup_renderer
      initial_calculations
      download_and_join_tiles
      @r.save(filename)
      filename
    end

    # Get proper renderer class
    def setup_renderer
      case @renderer
        when :chunky
          require 'gpx2png/chunky_png_renderer'
          @r = ChunkyPngRenderer.new
        else
          raise ArgumentError
      end
    end

  end
end