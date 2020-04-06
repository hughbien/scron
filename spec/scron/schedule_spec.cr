require "../spec_helper"

describe Scron::Schedule do
  describe "#initialize" do
    it "sets interval" do
      build_schedule(" 1d ", " echo ").interval.should eq(1)
    end

    it "sets command" do
      build_schedule(" 1d ", " echo hello world ").command.should eq("echo hello world")
    end

    it "raises error if line only has one part" do
      expect_raises(Scron::Error, "Unable to parse line: 1d") do
        Scron::Schedule.new("1d", Time.local)
      end
    end

    it "raises error if line has zero parts" do
      expect_raises(Scron::Error, "Unable to parse line: ") do
        Scron::Schedule.new("", Time.local)
      end
    end
  end

  describe "#overdue?" do
    it "returns true if command has no history" do
      history = build_history("")
      build_schedule.overdue?(history).should eq(true)
    end

    it "returns true if days since last run is greater than current interval" do
      now = Time.local
      last_run = now - 16.days
      history = build_history("#{last_run.to_s(Scron::TIME_FORMAT)} echo", now)
      schedule = build_schedule("15d", "echo", now)
      schedule.overdue?(history).should eq(true)
    end

    it "returns false if days since last run is equal to current interval" do
      now = Time.local
      last_run = now - 15.days
      history = build_history("#{last_run.to_s(Scron::TIME_FORMAT)} echo", now)
      schedule = build_schedule("15d", "echo", now)
      schedule.overdue?(history).should eq(false)
    end

    it "returns false if days since last run is less thancurrent interval" do
      now = Time.local
      last_run = now - 14.days
      history = build_history("#{last_run.to_s(Scron::TIME_FORMAT)} echo", now)
      schedule = build_schedule("15d", "echo", now)
      schedule.overdue?(history).should eq(false)
    end
  end

  # Each type of interval string (day of week/month/year) has two scenarios: when the specified
  # day falls before or after the current day. For example "15th" will return two vastly differing
  # values depending on if today is the 14th or 16th. On the 14th, the last run should be 1 day ago.
  # On the 16th, the last run should be almost a month ago.
  describe "#parse_days" do
    now = stub_now

    describe "for day of the week" do
      it "returns interval for past day" do
        build_schedule("Tu", "echo", now).interval.should eq(1)
      end

      it "returns interval for same day" do
        build_schedule("We", "echo", now).interval.should eq(0)
      end

      it "returns interval for future day" do
        build_schedule("Th", "echo", now).interval.should eq(6)
      end
    end

    describe "for day of the month" do
      it "returns interval for past day" do
        build_schedule("14th", "echo", now).interval.should eq(1)
      end

      it "returns interval for same day" do
        build_schedule("15th", "echo", now).interval.should eq(0)
      end

      it "returns interval for future day" do
        build_schedule("16th", "echo", now).interval.should eq(30)
      end

      it "returns intervals for all suffix types" do
        build_schedule("1st").interval.should_not be_nil
        build_schedule("2nd").interval.should_not be_nil
        build_schedule("3rd").interval.should_not be_nil
      end
    end

    describe "for day of the year" do
      it "returns interval for past day" do
        build_schedule("4/14", "echo", now).interval.should eq(1)
      end

      it "returns interval for same day" do
        build_schedule("4/15", "echo", now).interval.should eq(0)
      end

      it "returns interval for future day" do
        build_schedule("4/16", "echo", now).interval.should eq(365)
      end

      it "returns intervals for other months" do
        build_schedule("1/1", "echo", now).interval.should_not be_nil
        build_schedule("3/10", "echo", now).interval.should_not be_nil
        build_schedule("7/25", "echo", now).interval.should_not be_nil
        build_schedule("12/31", "echo", now).interval.should_not be_nil
      end
    end

    describe "for static number of days" do
      it "returns interval string as integer" do
        build_schedule("1d").interval.should eq(1)
        build_schedule("15d").interval.should eq(15)
        build_schedule("777d").interval.should eq(777)
      end
    end
  end

  describe ".parse" do
    it "ignores empty lines" do
      schedules = Scron::Schedule.parse("\n\n1d echo\n\n", Time.local)
      schedules.size.should eq(1)
    end

    it "ignores comment lines" do
      schedules = Scron::Schedule.parse("\n# comment\n1d echo\n  # comment 2  \n", Time.local)
      schedules.size.should eq(1)
    end

    it "returns schedules" do
      schedules = Scron::Schedule.parse("1d echo\n\n14d cat", Time.local)
      schedules.size.should eq(2)
      schedules.first.interval.should eq(1)
      schedules.first.command.should eq("echo")
      schedules.last.interval.should eq(14)
      schedules.last.command.should eq("cat")
    end
  end
end
