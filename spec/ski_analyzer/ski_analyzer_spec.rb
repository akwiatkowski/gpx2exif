require 'spec_helper'
require 'geokit'
require 'ski_analyzer'

describe SkiAnalyzer::Analyzer do
  it "should analyze GPX file created during ski activities" do
    f = File.join('spec', 'fixtures', 'ski.gpx')

    start = { lat: 50.8182855975, lon: 15.5173102207 }
    finish = { lat: 50.8058051113, lon: 15.5202671885 }

    g = SkiAnalyzer::Analyzer.new(f, start, finish)
  end
end
