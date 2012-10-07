require 'spec_helper'
require 'gpx2png/osm'
require 'gpx2png/ump'

describe Gpx2png::Osm do
  it "should create using GPX file with fixed size using OSM with 1 added point" do
    g = GpxUtils::TrackImporter.new
    g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))

    e = Gpx2png::Osm.new
    e.coords = g.coords

    e.simulate_download = true

    e.fixed_size(600, 600)
    e.add_marker(
      # blob: File.read("spec/fixtures/dot.png"), # added default marker
      label: 'start of track',
      lat: g.coords.first[:lat],
      lon: g.coords.first[:lon]
    )
    e.add_marker(
      # blob: File.read("spec/fixtures/dot.png"), # added default marker
      label: 'end of track',
      lat: g.coords.last[:lat],
      lon: g.coords.last[:lon]
    )
    e.save("samples/tmp/png_with_markerss.png")
  end
end
