require 'spec_helper'
require 'geotagger/geotagger'

describe Geotagger::Geotagger do
  it "should process everything from current path" do

    g = Geotagger::Geotagger.new
    g.add_all_files
    g.match_up
    g.save!
  end
end
