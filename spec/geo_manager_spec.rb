require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Gpx2exif::GeoManager do
  it "simple test" do
    g = Gpx2exif::GeoManager.new
    g.add_gpx_file(File.join('spec', 'fixtures', '1.gpx'))
    g.add_image(File.join('spec', 'fixtures', 'IMGP4206.JPG'))
    g.add_image(File.join('spec', 'fixtures', 'IMGP4207.JPG'))
    g.match_up
    g.save!
  end
end
