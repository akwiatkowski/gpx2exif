require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Gpx2png::Gpx2png do
  it "should create simple map" do
    e = Gpx2png::Gpx2png.new
    e.add(50.0, 20.0)
    e.add(51.0, 20.0)
    e.add(51.0, 21.0)
    e.add(50.0, 21.0)
    e.to_png

    puts e.dev.to_yaml
  end
end
