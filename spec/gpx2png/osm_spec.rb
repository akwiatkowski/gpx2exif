require 'spec_helper'
require 'gpx2png/osm'

describe Gpx2png::Osm do
  #it "should create simple map" do
  #  e = Gpx2png::Osm.new
  #  e.add(50.0, 20.0)
  #  e.add(51.0, 20.0)
  #  e.add(51.0, 21.0)
  #  e.add(50.0, 21.0)
  #  e.to_png('samples/png_sample1.png')
  #end
  #
  #it "should create using GPX file" do
  #  g = GpxUtils::TrackImporter.new
  #  g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))
  #
  #  e = Gpx2png::Osm.new
  #  e.coords = g.coords
  #  e.zoom = 8
  #  e.to_png('samples/png_sample2.png')
  #end

  it "should create using GPX file using chunky_png" do
    g = GpxUtils::TrackImporter.new
    g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))

    #e = Gpx2png::Osm.new
    #e.renderer = :chunky_png
    #e.coords = g.coords
    #e.zoom = 10
    #e.to_png('samples/png_sample3_chunky_png.png')

    e = Gpx2png::Osm.new
    e.fixed_size(1000, 1000)
    e.renderer = :rmagick
    e.renderer_options = {aa: true, color: '#0000FF', opacity: 0.5, crop_enabled: true}
    e.coords = g.coords
    e.zoom = 13
    #e.auto_zoom_for(2000,2000)

    e.to_png('samples/png_sample3_rmagick.png')
  end
end
