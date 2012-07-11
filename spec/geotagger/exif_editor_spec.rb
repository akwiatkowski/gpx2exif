require 'spec_helper'
require 'geotagger/geotagger'

describe Geotagger::ExifEditor do
  before :each do
    @path = File.join('spec', 'fixtures', 'sample.JPG')
  end

  it "should read image" do
    e = Geotagger::ExifEditor.new
    e.read_file(@path)
  end

  it "should get photo time" do
    e = Geotagger::ExifEditor.new
    t = e.get_photo_time(@path)
    t.should be_kind_of(Time)
  end
end
