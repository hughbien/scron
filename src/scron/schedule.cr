# Wraps a single line in the schedule file. Made up of two parts, the interval and the command. 
# Determines if a command is overdue and needs to be run. Does this by translating interval string
# into number of days since last run until command is considered overdue.
class Scron::Schedule
  getter command : String
  getter interval : Int32
  private getter now : Time

  WEEKDAYS = {"Mo" => 1, "Tu" => 2, "We" => 3, "Th" => 4, "Fr" => 5, "Sa" => 6, "Su" => 7}

  # Returns a schedule with an interval and command.
  # Example usage:
  #
  # ```
  # Scron::Schedule.new("Mo,We echo", Time.local) # run every Monday/Wednesday
  # Scron::Schedule.new("23rd echo", Time.local)  # run on the 23rd of every month
  # Scron::Schedule.new("12/25 echo", Time.local) # run on December 25th every year
  # Scron::Schedule.new("10d echo", Time.local)   # run once every 10 days
  # ```
  def initialize(line : String, @now : Time)
    parts = line.strip.split(/\s+/, 2)
    raise Error.new("Unable to parse line: #{line}") if parts.size != 2

    @interval = parts.first.split("\s*,\s*").map { |i| parse_days(i) }.min.to_i32
    @command = parts.last
  end

  # Returns true if command should run now, if it satisfies any of these conditions:
  # * command has never ran
  # * interval is past due, example: it last ran 15 days ago but the interval is every 14 days
  def overdue?(history : History)
    !history.has?(command) || (now - history[command]).days > interval
  end

  # Returns number of days passing until this interval is considered overdue. The interval string
  # should be in the format: day of the week, day of the month, day of the year, or number of days
  # since last run. Examples: `Mo`, `3rd`, `3/15`, `23d`.
  #
  # For all the examples below, pretend the current day is Wednesday 4/15:
  # * "We" returns 0, if it didn't run today it should now
  # * "Th" returns 6, if it didn't run last week it should now
  # * "10th" returns 5, if it didn't run 5 days ago it should now
  # * "16th" returns 30, if it didn't run 30 days ago in March it should now
  # * "4/10" returns 5, if it didn't run 5 days ago it should now
  # * "4/20" returns 360, if it didn't run last year on 4/20 it should now
  # * "15d" returns 15, meaning run every 15 days (the only format that doesn't depend on current day)
  private def parse_days(interval_str)
    if WEEKDAYS.has_key?(interval_str) # day of week, eg "Mo" or "Tu"
      (now.day_of_week.value - WEEKDAYS[interval_str]) % 7
    elsif interval_str =~ /^(\d+)(st|nd|rd|th)$/ # day of month, eg "1st" or "15th"
      day = $1.to_i
      now.day >= day ? now.day - day : (now - last_month(day).not_nil!).days
    elsif interval_str =~ /^(\d+)\/(\d+)$/ # day of year, eg "4/15" or "7/4"
      year, month, day = now.year, $1.to_i, $2.to_i
      year -= 1 if now.month < month || (now.month == month && now.day < day)
      (now - Time.local(year, month, day, now.hour, now.minute, now.second)).days
    elsif interval_str =~ /^(\d+)d$/ # every few of days, eg "1d" or "14d"
      $1.to_i
    else
      raise Error.new("Unable to parse: #{interval_str}")
    end
  end

  # Returns one month ago, on this day. Return the last day of the month if this particular day
  # doesn't exist in the month. For example, passing in March 31st might return February 28th.
  private def last_month(day)
    last = now - 1.month
    [day, 30, 29, 28].each do |d|
      time = Time.local(last.year, last.month, d, now.hour, now.minute, now.second) rescue nil
      return time if time
    end
  end

  # Given the text of a schedule file, parses it and returns an Array of Schedules.
  # Lines prefixed with `#` are ignored as a comment. Empty lines are also ignored.
  def self.parse(text : String, now : Time) : Array(Scron::Schedule)
    text.split("\n").
      reject { |line| self.is_empty?(line) || self.is_comment?(line) }.
      map { |line| self.new(line, now) }
  end

  # Returns true for empty lines.
  private def self.is_empty?(line : String)
    line =~ /^\s*#/
  end

  # Returns true for comment lines (starts with "#").
  private def self.is_comment?(line : String)
    line =~ /^\s*$/
  end

end
