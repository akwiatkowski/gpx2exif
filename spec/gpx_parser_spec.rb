require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Gpx2exif::GpxParser do
  it "parsing gpx file" do
    g = Gpx2exif::GpxParser.new
    g.add_file(File.join('spec', 'fixtures', '1.gpx'))
    # TODO add more tests
  end
end
