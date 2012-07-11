require 'rubygems'

$:.unshift(File.dirname(__FILE__))

module Gpx2png
  class Base

    def initialize
      @coords = Array.new
      @zoom = 9
    end

    def add(lat, lon)
      @coords << { lat: lat, lon: lon }
    end

    attr_accessor :zoom, :color, :coords

    # Some math stuff
    def self.rad2deg(rad)
      return rad * 180.0 / Math::PI
    end

    def self.deg2rad(deg)
      return deg * Math::PI / 180.0
    end

  end
end