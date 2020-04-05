require "../spec_helper"

describe Scron::Command do
  describe "#run" do
    it "prints help on --help" do
      io = String::Builder.new
      Scron::Command.new(["-h"], io).run
      io.to_s.should contain("Usage: scron")
    end

    it "prints version on --version" do
      io = String::Builder.new
      Scron::Command.new(["-v"], io).run
      io.to_s.should contain(Scron::VERSION)
    end

    it "prints error on invalid option" do
      io = String::Builder.new
      Scron::Command.new(["--nope"], io).run
      io.to_s.should contain("Invalid option: --nope")
    end
  end
end
