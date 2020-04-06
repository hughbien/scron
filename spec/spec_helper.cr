require "spec"
require "../src/scron"

# Wednesday April 15, 2020
def stub_now
  Time.local(2020, 4, 15, 12, 0, 0)
end

def setup_tempfile(content = nil)
  file = File.tempfile
  File.write(file.path, content) if content
  file
end

def build_runner(schedule_file = nil, history_file = nil, log_file = nil, now = Time.local)
  temp_schedule = File.tempfile if schedule_file.nil?
  temp_history = File.tempfile if history_file.nil?
  temp_log = File.tempfile if log_file.nil?

  runner = Scron::Runner.new(
    schedule_file || temp_schedule.not_nil!.path,
    history_file || temp_history.not_nil!.path,
    log_file || temp_log.not_nil!.path,
    now
  )
  yield runner

  temp_schedule.not_nil!.delete if temp_schedule
  temp_history.not_nil!.delete if temp_history
  temp_log.not_nil!.delete if temp_log
end

def build_schedule(interval = "1d", command = "echo", now = Time.local)
  Scron::Schedule.new("#{interval} #{command}", now)
end

def build_history(text = nil, now = Time.local)
  text ||= "#{now.to_s(Scron::TIME_FORMAT)} echo"
  Scron::History.new(text, now)
end
