require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GarminUtils::WaypointListGenerator do
  it "should create empty waypoint xml/gpx" do
    g = GarminUtils::WaypointListGenerator.new
    xml = g.to_xml
    xml.should be_kind_of(String)

    #puts xml
  end

  it "should create xml with 1 poi" do
    g = GarminUtils::WaypointListGenerator.new
    lat = 52.384444
    lon = 16.193056
    g.add(lat, lon, 'test', nil, Time.now - 3600, 120, nil)

    xml = g.to_xml
    xml.should be_kind_of(String)
    xml.should include(lat.to_s)
    xml.should include(lon.to_s)
  end
end
