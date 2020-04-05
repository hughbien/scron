require "../spec_helper"

describe Scron::Schedule do
  describe "#initialize" do
    it "sets interval" do
      schedule = Scron::Schedule.new(" 1d  echo ")
      schedule.interval.should eq("1d")
    end

    it "sets command" do
      schedule = Scron::Schedule.new(" 1d  echo hello world ")
      schedule.command.should eq("echo hello world")
    end

    it "raises error if line only has one part" do
      expect_raises(Scron::Error, "Unable to parse line: 1d") do
        Scron::Schedule.new("1d")
      end
    end

    it "raises error if line has zero parts" do
      expect_raises(Scron::Error, "Unable to parse line: ") do
        Scron::Schedule.new("")
      end
    end
  end

  describe "#run" do
  end

  describe ".parse" do
    it "ignores empty lines" do
      schedules = Scron::Schedule.parse("\n\n1d echo\n\n")
      schedules.size.should eq(1)
    end

    it "ignores comment lines" do
      schedules = Scron::Schedule.parse("\n# comment\n1d echo\n  # comment 2  \n")
      schedules.size.should eq(1)
    end

    it "returns schedules" do
      schedules = Scron::Schedule.parse("1d echo\n\n2w cat")
      schedules.size.should eq(2)
      schedules.first.interval.should eq("1d")
      schedules.first.command.should eq("echo")
      schedules.last.interval.should eq("2w")
      schedules.last.command.should eq("cat")
    end
  end
end
