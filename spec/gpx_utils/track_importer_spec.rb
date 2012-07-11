require 'spec_helper'

describe GpxUtils::TrackImporter do
  it "should parse garmin etrex gpx file" do
    g = GpxUtils::TrackImporter.new
    g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))
    g.coords.should be_kind_of(Array)
    g.coords.size.should == 602
    g.coords.each do |coord|
      coord[:lat].should be_kind_of(Float)
      coord[:lon].should be_kind_of(Float)

      coord[:lat].should_not == 0.0
      coord[:lon].should_not == 0.0
    end
  end
end
