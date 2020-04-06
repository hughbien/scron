require "../spec_helper"
require "uuid"

describe Scron::Runner do
  now = stub_now
  now_str = now.to_s(Scron::TIME_FORMAT)

  describe "#run" do
    it "raises error if schedule file does not exist" do
      build_runner(schedule_file: "/path/to/schedule") do |runner|
        expect_raises(Scron::Error, "File does not exist: /path/to/schedule") do
          runner.run
        end
      end
    end

    it "runs overdue command" do
      uuid = UUID.random
      schedule_file = setup_tempfile("1d echo #{uuid}")
      history_file = setup_tempfile("2020-04-13.12:00:00 echo #{uuid}")
      log_file = setup_tempfile

      build_runner(
        schedule_file: schedule_file.path,
        history_file: history_file.path,
        log_file: log_file.path,
        now: now
      ) do |runner|
        runner.run

        history = Scron::History.new(File.read(history_file.path), now)
        history["echo #{uuid}"].should eq(now)

        log = File.read(log_file.path)
        log.should contain("=> #{now_str} echo #{uuid} (start)")
        log.should contain("=> #{now_str} echo #{uuid} (exit=0)")
      end

      schedule_file.delete
      history_file.delete
      log_file.delete
    end

    it "does not run non-overdue commands" do
      schedule_file = setup_tempfile("30d echo")
      history_file = setup_tempfile("2020-04-14.12:00:00 echo")
      log_file = setup_tempfile

      build_runner(
        schedule_file: schedule_file.path,
        history_file: history_file.path,
        log_file: log_file.path,
        now: now
      ) do |runner|
        runner.run

        history = Scron::History.new(File.read(history_file.path), now)
        history.has?("echo").should eq(true)
        history["echo"].should_not eq(now)

        log = File.read(log_file.path)
        log.should_not contain("echo")
      end

      schedule_file.delete
      history_file.delete
      log_file.delete
    end

    it "does not write to history on command failure" do
      schedule_file = setup_tempfile("1d unknown-command") # TODO: hide stderr output
      history_file = setup_tempfile
      log_file = setup_tempfile

      build_runner(
        schedule_file: schedule_file.path,
        history_file: history_file.path,
        log_file: log_file.path,
        now: now
      ) do |runner|
        runner.run

        history = Scron::History.new(File.read(history_file.path), now)
        history.has?("unknown-command").should eq(false)

        log = File.read(log_file.path)
        log.should contain("=> #{now_str} unknown-command (start)")
        log.should_not contain("=> #{now_str} unknown-command (exit=0)")
      end

      schedule_file.delete
      history_file.delete
      log_file.delete
    end

    it "logs when starting/finishing scron" do
      log_file = setup_tempfile
      build_runner(log_file: log_file.path, now: now, &.run)
      log = File.read(log_file.path)
      log.should contain("=> #{now_str} running")
      log.should contain("=> #{now_str} finished")
      log_file.delete
    end
  end
end
