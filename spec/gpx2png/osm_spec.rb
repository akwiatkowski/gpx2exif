require 'spec_helper'
require 'gpx2png/osm'

describe Gpx2png::Osm do
  #it "should create simple map" do
  #  e = Gpx2png::Osm.new
  #  e.add(50.0, 20.0)
  #  e.add(51.0, 20.0)
  #  e.add(51.0, 21.0)
  #  e.add(50.0, 21.0)
  #  e.save('samples/tmp/png_sample1.png')
  #end
  #
  #it "should create using GPX file" do
  #  g = GpxUtils::TrackImporter.new
  #  g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))
  #
  #  e = Gpx2png::Osm.new
  #  e.coords = g.coords
  #  e.zoom = 8
  #  e.save('samples/tmp/png_sample2.png')
  #end

  it "should create using GPX file using chunky_png" do
    g = GpxUtils::TrackImporter.new
    g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))

    e = Gpx2png::Osm.new
    e.renderer = :chunky_png
    e.coords = g.coords
    e.zoom = 10
    e.save('samples/tmp/png_sample3_chunky_png.png')
  end

  it "should create using GPX file using rmagick" do
    g = GpxUtils::TrackImporter.new
    g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))

    e = Gpx2png::Osm.new
    #e.fixed_size(1500, 1500)
    e.renderer = :rmagick
    e.renderer_options = {aa: true, color: '#0000FF', opacity: 0.5, crop_enabled: true}
    e.coords = g.coords
    e.zoom = 13
    #e.auto_zoom_for(2000,2000)

    e.save('samples/tmp/png_sample3_rmagick.png')
  end

  it "should create using GPX file using rmagick with fixed resolutions" do
    g = GpxUtils::TrackImporter.new
    g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))

    resolutions = [
      [300,200],
      [600,800],
      [800,800],
      [1000,400],
      [1100,1100],
      [2000,2000]
    ]

    resolutions.each do |resolution|
      width = resolution[0]
      height = resolution[1]

      e = Gpx2png::Osm.new
      e.fixed_size(width, height)
      e.renderer = :rmagick
      e.renderer_options = {aa: false, color: '#0000FF', opacity: 0.5, crop_enabled: true}
      e.coords = g.coords
      #e.zoom = 13
      e.save("samples/tmp/png_sample4_rmagick_fixed_#{width}_#{height}.png")
    end


  end
end
