#require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'spec_helper'

describe GarminUtils::WaypointsImporter do
  it "should parse garmin etrex gpx file and get all waypoints" do
    g = GarminUtils::WaypointsImporter.new
    g.add_file(File.join('spec', 'fixtures', 'sample_waypoint.gpx'))
    pois = g.pois

    pois.size.should == 2
    pois.select{|p| p[:name] == 'SKLEP'}.size == 1
    pois.select{|p| p[:sym] == 'Trail Head'}.size == 2
  end
end
