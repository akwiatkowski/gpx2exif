require 'rubygems'
require 'nokogiri'

$:.unshift(File.dirname(__FILE__))

module Gpx2exif
  class GpxParser

    THRESHOLD = 5*60

    def initialize
      @coords = Array.new
    end

    def add_file(path, time_offset = 0)
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
          :time => proc_time(wpt.xpath('time').children.first.to_s, time_offset),
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

      a = a.sort { |b, c| b[:time] <=> c[:time] }
      time_substring = " from #{a.first[:time]} to #{a.last[:time]}, " if a.size > 0
      puts "Imported #{a.size} coords,#{time_substring}#{error_count} errors"
      @coords += a
    end

    def proc_time(ts, time_offset)
      if ts =~ /(\d{4})-(\d{2})-(\d{2})T(\d{1,2}):(\d{2}):(\d{2})Z/
        return Time.gm($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i).localtime + time_offset
      end
    end

    def find_by_time(time)
      selected_coords = @coords.select { |c| (c[:time].localtime - time.localtime).abs < THRESHOLD }
      selected_coords = selected_coords.sort { |a, b| (a[:time].localtime - time.localtime).abs <=> (b[:time].localtime - time.localtime).abs }
      puts " - found #{selected_coords.size} coords within #{THRESHOLD}s from image time"
      if selected_coords.size > 0
        puts " - best is #{selected_coords.first[:time].localtime}, time offset #{selected_coords.first[:time].localtime - time.localtime}"
        puts " - lat #{selected_coords.first[:lat]} lon #{selected_coords.first[:lon]}"
      end

      return selected_coords.first
    end

  end
end