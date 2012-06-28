require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Gpx2png::Gpx2png do
  it "should create simple map" do
    e = Gpx2png::Gpx2png.new
    e.add(50.0, 20.0)
    e.add(51.0, 20.0)
    e.add(51.0, 21.0)
    e.add(50.0, 21.0)
    e.to_png('samples/png_sample1.png')
  end

  it "should create using GPX file" do
    g = Gpx2exif::GpxParser.new
    g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))

    e = Gpx2png::Gpx2png.new
    e.coords = g.coords
    e.zoom = 15
    e.to_png('samples/png_sample2.png')
  end
end
