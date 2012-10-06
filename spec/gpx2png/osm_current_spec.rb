require 'spec_helper'
require 'gpx2png/osm'
require 'gpx2png/ump'

describe Gpx2png::Osm do
  it "should create using GPX file with fixed size using OSM and UMP" do
    g = GpxUtils::TrackImporter.new
    g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))

    [Gpx2png::Ump.new, Gpx2png::Osm.new].each do |e|
      e.coords = g.coords
      e.fixed_size(2000, 2000)
      e.save("samples/tmp/png_sample2_chunky_real_route_#{e.class.to_s.gsub(/\W/, '_')}.png")
    end
  end
end
