require "../scron"

# Runs overdue jobs and updates relevant files. Responsibilities include:
# * parsing the schedule file
# * using `Schedule` and `History` to determine which jobs are overdue
# * running overdue jobs and updating the history/log files
class Scron::Runner
  private getter schedule_file, history_file, log_file

  def initialize(@schedule_file : String, @history_file : String, @log_file : String)
  end

  def run
    [schedule_file, history_file, log_file].each do |file|
      raise Error.new("File does not exist: #{file}") unless File.exists?(file)
    end

    schedules = Schedule.parse(File.read(schedule_file))
    schedules.each do |schedule|
      output = execute(schedule.command)
    end
  end

  private def execute(command)
    `#{command}`
  rescue error : Exception
    error.to_s
  end
end
