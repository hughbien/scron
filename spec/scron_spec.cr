require "./spec_helper"

describe Scron do
  it "sets VERSION" do
    Scron::VERSION.empty?.should eq(false)
  end
end
