require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GarminUtils::WaypointListGenerator do
  it "should create empty xml" do
    g = GarminUtils::WaypointListGenerator.new
    xml = g.to_xml
    xml.should be_kind_of(String)

    #puts xml
  end

  it "should create xml with 1 poi" do
    g = GarminUtils::WaypointListGenerator.new
    # <wpt lat="52.484444" lon="16.893056"><ele>113.286499</ele><time>2012-03-18T16:42:47Z</time><name>GORA MORASKO</name><cmt>DUZY</cmt><sym>Flag, Blue</sym></wpt>
    g.add(52.384444, 16.193056, 'test', nil, Time.now - 3600, 120, nil)

    xml = g.to_xml
    xml.should be_kind_of(String)
    puts xml
  end
end
