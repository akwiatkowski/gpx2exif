require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Gpx2exif::GeoManager do
  it "should process everything from current path" do
    g = Gpx2exif::GeoManager.new
    g.add_all_files
    g.match_up
    g.save!
  end
end
