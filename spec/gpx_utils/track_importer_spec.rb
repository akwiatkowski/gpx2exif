require 'spec_helper'

describe GpxUtils::TrackImporter do
  it "should parse garmin etrex gpx file" do
    g = GpxUtils::TrackImporter.new
    g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))
    # TODO add more tests
  end
end
