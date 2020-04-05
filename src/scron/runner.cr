require "../scron"

# Runs overdue jobs and updates relevant files. Responsibilities include:
# * parsing the schedule file
# * using `Schedule` and `History` to determine which jobs are overdue
# * running overdue jobs and updating the history/log files
class Scron::Runner
  private getter schedule_file : String
  private getter history_file : String
  private getter log_file : String

  private getter now : Time
  private getter now_str : String

  def initialize(@schedule_file, @history_file, @log_file, @now = Time.local)
    @now_str = @now.to_s(TIME_FORMAT)
  end

  def run
    raise Error.new("File does not exist: #{schedule_file}") unless File.exists?(schedule_file)

    logger = File.open(log_file, "a")
    logger.puts("=> #{now_str} running")

    schedules = Schedule.parse(File.read(schedule_file))
    schedules.each do |schedule|
      logger.puts("=> #{now_str} #{schedule.command} (start)")
      output, status = execute(schedule.command)
      logger.puts("=> #{now_str} #{schedule.command} (exit=#{status})")
      logger.puts(output) unless output.empty?
    end
  ensure
    if logger
      logger.puts("=> #{now_str} finished")
      logger.close
    end
  end

  private def execute(command)
    [`#{command}`, $?.exit_status.to_s]
  rescue error : Exception
    [error.to_s, "error"]
  end
end
