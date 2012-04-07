require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Gpx2exif::ExifEditor do
  before :each do
    @path = File.join('spec', 'fixtures', 'sample.JPG')
  end

  it "should read image" do
    e = Gpx2exif::ExifEditor.new
    e.read_file(@path)
  end

  it "should get photo time" do
    e = Gpx2exif::ExifEditor.new
    t = e.get_photo_time(@path)
    t.should be_kind_of(Time)
  end
end
