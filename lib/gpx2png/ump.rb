require 'rubygems'
require 'gpx2png/osm'

$:.unshift(File.dirname(__FILE__))

module Gpx2png
  class Ump < Osm

    # Convert OSM/UMP tile coords to url
    def self.url(zoom, coord, server = '3.')
      x, y = coord
      url = "http://#{server}tiles.ump.waw.pl/ump_tiles/#{zoom}/#{x}/#{y}.png"
      return url
    end

    def self.licence_string
      "Data by UMP-pcPL+SRTM"
    end

  end
end