require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Gpx2exif do
  it "should has gem main module" do
    Gpx2exif.should be_kind_of(Module)
  end
end
