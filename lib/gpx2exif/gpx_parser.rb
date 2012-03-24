require 'rubygems'
require 'nokogiri'

$:.unshift(File.dirname(__FILE__))

module Gpx2exif
  class GpxParser

    def initialize
      @coords = Array.new
    end

    def add_file(path)
      f = File.new(path)
      doc = Nokogiri::XML(f)
      doc.remove_namespaces!
      a = Array.new
      error_count = 0

      trackpoints = doc.xpath('//gpx/trk/trkseg/trkpt')
      trackpoints.each do |wpt|
        w = {
          :lat => wpt.xpath('@lat').to_s.to_f,
          :lon => wpt.xpath('@lon').to_s.to_f,
          :time => proc_time(wpt.xpath('time').children.first.to_s),
          :ele => wpt.xpath('ele').children.first.to_s.to_f
        }
        if not w[:lat].nil? and not w[:lat] == 0.0 and
          not w[:lon].nil? and not w[:lon] == 0.0 and
          not w[:time].nil?
          a << w
        else
          error_count += 1
        end
        
      end

      f.close
      puts "Imported #{a.size} coords, #{error_count} errors"
      @coords += a
    end

    def proc_time(ts)
      if ts =~ /(\d{4})-(\d{2})-(\d{2})T(\d{1,2}):(\d{2}):(\d{2})Z/
        return Time.mktime($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i)
      end
    end

  end
end