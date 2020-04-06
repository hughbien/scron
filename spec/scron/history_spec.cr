require "../spec_helper"

describe Scron::History do
  now = stub_now

  describe "#initialize" do
    it "sets now" do
      history = build_history("2020-01-01.06:00 echo", now)
      history.touch("test")
      history["test"].should eq(now)
    end

    it "sets history" do
      history = build_history("2020-01-01.06:00 echo", now)
      history["echo"].should eq(Time.local(2020, 1, 1, 6, 0, 0))
    end
  end

  describe "#has?" do
    it "returns true if command exists in history" do
      build_history("2020-01-01.06:00 echo", now).has?("echo").should eq(true)
    end

    it "returns false if command never ran" do
      build_history("").has?("echo").should eq(false)
    end
  end

  describe "#[]" do
    it "returns timestamp of last run" do
      build_history("2020-04-15.12:00 echo", now)["echo"].should eq(now)
    end

    it "raises if command never ran" do
      expect_raises(Scron::Error, "Command never ran: echo") do
        build_history("", now)["echo"]
      end
    end
  end

  describe "#touch" do
    it "sets timestamp for new command" do
      history = build_history("", now)
      history.touch("echo")
      history["echo"].should eq(now)
    end

    it "sets new timestamp for existing command" do
      history = build_history("2020-01-01.06:00 echo", now)
      history.touch("echo")
      history["echo"].should eq(now)
    end
  end

  describe "#to_s" do
    history_str = "2020-01-01.06:00 echo1\n2020-04-15.12:00 echo2\n"

    it "builds history database as a string via memory" do
      history = build_history(history_str, now)
      history.to_s(IO::Memory.new).to_s.should eq(history_str)
    end

    it "returns history database as a string" do
      build_history(history_str, now).to_s.should eq(history_str)
    end
  end
end
