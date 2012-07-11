require 'rubygems'
require 'chunky_png'

$:.unshift(File.dirname(__FILE__))

module Gpx2png
  class ChunkyPngRenderer
    def initialize
      @color = ChunkyPNG::Color.from_hex('#FF0000')
    end
  end
end