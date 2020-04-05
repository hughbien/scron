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

    log = File.open(log_file, "a")
    log.puts("=> #{now_str} running")

    schedules = Schedule.parse(File.read(schedule_file))
    history = History.new(read_history_file, now)

    schedules.each do |schedule|
      log.puts("=> #{now_str} #{schedule.command} (start)")
      output, status = execute(schedule.command)
      log.puts("=> #{now_str} #{schedule.command} (exit=#{status})")
      log.puts(output) unless output.empty?

      if status == "0"
        history.touch(schedule.command)
        File.write(history_file, history.to_s)
      end
    end
  ensure
    if log
      log.puts("=> #{now_str} finished")
      log.close
    end
  end

  private def execute(command)
    [`#{command}`, $?.exit_status.to_s]
  rescue error : Exception
    [error.to_s, "error"]
  end

  private def read_history_file
    File.exists?(history_file) ? File.read(history_file) : ""
  end
end
