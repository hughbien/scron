require "../spec_helper"

describe Scron::Runner do
  describe "#run" do
    it "raises error if schedule file does not exist" do
      build_runner(schedule_file: "/path/to/schedule") do |runner|
        expect_raises(Scron::Error, "File does not exist: /path/to/schedule") do
          runner.run
        end
      end
    end
  end
end
