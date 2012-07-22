require 'spec_helper'
require 'gpx2png/osm'

describe Gpx2png::Osm do
  begin
    require 'RMagick'
    @rmagick = true
  rescue
    puts "RMagick not available"
    @rmagick = false
  end

  begin
    require 'chunky_png'
    @chunky = true
  rescue
    puts "chunky_png not available"
    @chunky = false
  end

  if @rmagick
    it "should create simple map" do
      e = Gpx2png::Osm.new
      e.add(50.0, 20.0)
      e.add(51.0, 20.0)
      e.add(51.0, 21.0)
      e.add(50.0, 21.0)
      e.save('samples/tmp/png_sample1_simple.png')
    end

    it "should create using GPX file with set zoom" do
      g = GpxUtils::TrackImporter.new
      g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))

      e = Gpx2png::Osm.new
      e.coords = g.coords
      e.zoom = 8
      e.save('samples/tmp/png_sample2_real_route.png')
    end

    it "should create using GPX file with some renderer options" do
      g = GpxUtils::TrackImporter.new
      g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))

      e = Gpx2png::Osm.new
      e.renderer = :rmagick
      e.renderer_options = { aa: true, color: '#0000FF', opacity: 0.5, crop_enabled: true }
      e.coords = g.coords
      e.zoom = 13

      e.save('samples/tmp/png_sample3_with_option.png')
    end

    it "should create using GPX file with some fixed resolutions" do
      g = GpxUtils::TrackImporter.new
      g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))

      resolutions = [
        [80, 80],
        [300, 200],
        [600, 800],
        [800, 800],
        [1000, 400],
        [1100, 1100],
        [2000, 2000]
      ]

      resolutions.each do |resolution|
        width = resolution[0]
        height = resolution[1]

        e = Gpx2png::Osm.new
        #e.simulate_download = true
        e.fixed_size(width, height)
        #e.renderer_options = { aa: false, color: '#0000FF', opacity: 0.5, crop_enabled: true }
        e.coords = g.coords
        e.save("samples/tmp/png_sample4_simulation_fixed_#{width}_#{height}.png")
      end
    end
  end


  if @chunky
    it "should create using GPX file with set zoom using chunky renderer" do
      g = GpxUtils::TrackImporter.new
      g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))

      e = Gpx2png::Osm.new
      e.renderer = :chunky_png
      e.coords = g.coords
      e.zoom = 8
      e.save('samples/tmp/png_sample2_chunky_real_route.png')
    end
  end

end
