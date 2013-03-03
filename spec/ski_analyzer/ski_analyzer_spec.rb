require 'spec_helper'
require 'ski_analyzer'

describe SkiAnalyzer::Analyzer do
  it "should analyze GPX file created during ski activities" do
    f = File.join('spec', 'fixtures', 'ski.gpx')
    g = SkiAnalyzer::Analyzer.new(f)
  end
end
