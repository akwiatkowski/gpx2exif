#!/usr/bin/env ruby

require 'rubygems'
require 'gpx2exif'

puts "Are you sure? It is evil script which probably eat photos of your dog and family. Uppercase 'yes' and enter if you want to continue."
str = gets

exit(0) unless str.strip == 'YES'

g = Gpx2exif::GeoManager.new
g.add_all_files
g.match_up
g.save!