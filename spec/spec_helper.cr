require "spec"
require "../src/scron"

def build_runner(schedule_file = nil, history_file = nil, log_file = nil)
  temp_schedule = File.tempfile if schedule_file.nil?
  temp_history = File.tempfile if history_file.nil?
  temp_log = File.tempfile if log_file.nil?

  runner = Scron::Runner.new(
    schedule_file || temp_schedule.not_nil!.path,
    history_file || temp_history.not_nil!.path,
    log_file || temp_log.not_nil!.path
  )
  yield runner

  temp_schedule.not_nil!.delete if temp_schedule
  temp_history.not_nil!.delete if temp_history
  temp_log.not_nil!.delete if temp_log
end
