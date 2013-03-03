require 'gpx_utils/waypoints_importer'

module SkiAnalyzer
  class Analyzer
    def initialize(gpx_file)
      @file = gpx_file

      @i = GpxUtils::TrackImporter.new
      @i.add_file(@file)

      puts @i.coords.size
    end
  end
end
