require 'rubygems'
require 'builder'
require 'yaml'

$:.unshift(File.dirname(__FILE__))

module GarminUtils
  class WaypointListGenerator

    def initialize
      @pois = Array.new
      @etrex_model = "eTrex 30"
    end

    def add_yaml_file(y)
      @pois += YAML::load_file(y)
    end

    def add(lat, lon, name, cmt = nil, time = nil, ele = nil, sym = nil)
      @pois << {
              :lat => lat,
              :lon => lon,
              :name => name,
              :cmt => cmt,
              :time => time,
              :ele => ele,
              :sym => sym
      }
    end

    def to_xml
      #xml = Builder::XmlMarkup.new(:indent => 2)
      string = ""
      xml = Builder::XmlMarkup.new(:target => string, :indent => 0)
      xml.instruct! :xml, :encoding => "UTF-8", :standalone => 'no'
      xml.gpx(
              'xmlns' => "http://www.topografix.com/GPX/1/1",
              'xmlns:gpxx' => "http://www.garmin.com/xmlschemas/GpxExtensions/v3",
              'xmlns:wptx1' => "http://www.garmin.com/xmlschemas/WaypointExtension/v1",
              'xmlns:gpxtpx' => "http://www.garmin.com/xmlschemas/TrackPointExtension/v1",
              'creator' => @etrex_model,
              'version' => "1.1",
              'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
              'xsi:schemaLocation' => "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www8.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/WaypointExtension/v1 http://www8.garmin.com/xmlschemas/WaypointExtensionv1.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd"


      ) do |g|
        g.metadata do |meta|
          meta.link('href' => "http://www.garmin.com") do |link|
            link.text 'Garmin International'
          end
          meta.time process_time(Time.now) # 2012-03-24T15:41:34Z
        end

        # coords
        # <wpt lat="52.484444" lon="16.893056"><ele>113.286499</ele><time>2012-03-18T16:42:47Z</time><name>GORA MORASKO</name><cmt>DUZY</cmt><sym>Flag, Blue</sym></wpt>
        @pois.each do |poi|
          g.wpt('lat' => poi[:lat], 'lon' => poi[:lon]) do |wp|
            wp.ele poi[:elevation] unless poi[:elevation].nil?
            wp.ele poi[:ele] unless poi[:ele].nil?

            unless poi[:time].nil?
              wp.time process_time(poi[:time])
            else
              wp.time process_time(Time.now)
            end
            wp.name poi[:name]

            wp.cmt poi[:comment] unless poi[:comment].nil?
            wp.cmt poi[:cmt] unless poi[:cmt].nil?

            wp.sym poi[:sym] || "Flag, Blue" # default garmin symbol
          end
        end
      end

      #return string
      return string.gsub(/\n/, '').gsub(/\r/, '')

    end

    attr_reader :pois

    def self.symbols
      # http://freegeographytools.com/2008/garmin-gps-unit-waypoint-icons-table
      [
              "Flag, Blue",
              "Flag, Green",
              "Flag, Red",

              "Pin, Blue",
              "Pin, Green",
              "Pin, Red",

              "Block, Blue",
              "Block, Green",
              "Block, Red",

              "Summit",
              "Trail Head"
              # ...

      ]
    end

    def process_time(time)
      time.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
    end

  end
end