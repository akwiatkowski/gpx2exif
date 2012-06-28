require 'rubygems'

$:.unshift(File.dirname(__FILE__))

module Gpx2png
  class Gpx2png

    def initialize
      @coords = Array.new
    end

    def add(lat, lon)
      @coords << { lat: lat, lon: lon }
    end

    def dev
      @coords.collect{|c| self.class.url(5, c[:lat], c[:lon])}
    end

    def to_png
      nil
    end

    # http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#X_and_Y
    def self.convert(zoom, lat_deg, lon_deg)
      lat_rad = deg2rad(lat_deg)
      x = (((lon_deg + 180) / 360) * (2 ** zoom)).floor
      y = ((1 - Math.log(Math.tan(lat_rad) + 1 / Math.cos(lat_rad)) / Math::PI) /2 * (2 ** zoom)).floor

      return [x,y]
    end

    def self.url(zoom, lat_rad, lon_deg, server = 'b.')
      x, y = convert(zoom, lat_rad, lon_deg)
      url = "http://#{server}tile.openstreetmap.org\/#{zoom}\/#{x}\/#{y}.png"
      return url
    end

    def self.reverse_convert(zoom, x, y)
      n = 2 ** zoom
      lon_deg = x / n * 360.0 - 180.0
      lat_deg = rad2deg(atan(sinh(pi() * (1 - 2 * $ytile / $n))));
    end

    def self.rad2deg(rad)
      return rad * 180.0 / Math::PI
    end

    def self.deg2rad(deg)
      return deg * Math::PI / 180.0
    end


  end
end