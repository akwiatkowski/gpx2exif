require 'rubygems'

$:.unshift(File.dirname(__FILE__))

module GarminUtils
  class WaypointsImporter

    def initialize
      @pois = Array.new
    end

    attr_reader :pois

    def add_file(y)
      @pois += parse_gpx_file(y)
    end

    def parse_gpx_file(path)
      f = File.new(path)
      doc = Nokogiri::XML(f)
      doc.remove_namespaces!
      a = Array.new

      trackpoints = doc.xpath('//gpx/wpt')
      trackpoints.each do |wpt|
        w = {
          :lat => wpt.xpath('@lat').to_s.to_f,
          :lon => wpt.xpath('@lon').to_s.to_f,
          :time => Gpx2exif::GpxParser.proc_time(wpt.xpath('time').children.first.to_s),
          :alt => wpt.xpath('ele').children.first.to_s.to_f,
          :name => wpt.xpath('name').children.first.to_s,
          :sym => wpt.xpath('sym').children.first.to_s
        }
          a << w
      end
      f.close

      return a
    end

    #def add(lat, lon, name, cmt = nil, time = nil, ele = nil, sym = nil)
    #  @pois << {
    #    :lat => lat,
    #    :lon => lon,
    #    :name => name,
    #    :cmt => cmt,
    #    :time => time,
    #    :ele => ele,
    #    :sym => sym
    #  }
    #end

  end
end