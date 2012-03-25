require 'rubygems'
require 'gpx2exif'

g = Gpx2exif::GeoManager.new
g.add_all_files
g.match_up
g.save!