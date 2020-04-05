# Wraps a single line in the schedule file. Made up of two parts, the interval and the command. 
# Determines if a command is overdue and needs to be run.
class Scron::Schedule
  getter command : String
  getter interval : Int32
  private getter now : Time

  WEEKDAYS = {"Mo" => 1, "Tu" => 2, "We" => 3, "Th" => 4, "Fr" => 5, "Sa" => 6, "Su" => 7}

  def initialize(line : String, @now : Time)
    parts = line.strip.split(/\s+/, 2)
    raise Error.new("Unable to parse line: #{line}") if parts.size != 2

    @interval = parts.first.split("\s*,\s*").map { |i| parse_days(i) }.min.to_i32
    @command = parts.last
  end

  def overdue?(history : History)
    !history.has?(command) || (now - history[command]).days > interval
  end

  # Given the text of a schedule file, parses it and returns an Array of Schedules.
  # Lines prefixed with `#` are ignored as a comment.
  # Empty lines are also ignored.
  def self.parse(text : String, now : Time) : Array(Scron::Schedule)
    text.split("\n").
      reject { |line| self.is_empty?(line) || self.is_comment?(line) }.
      map { |line| self.new(line, now) }
  end

  private def self.is_empty?(line : String)
    line =~ /^\s*#/
  end

  private def self.is_comment?(line : String)
    line =~ /^\s*$/
  end

  # maximum day count requirement for interval to be considered overdue
  # eg "15d" means if command was run "16d" ago it's overdue, if "14d" ago it's not overdue
  private def parse_days(interval_str)
    if WEEKDAYS.has_key?(interval_str) # specific day of week, eg "Mo" or "Tu"
      (now.day_of_week.value - WEEKDAYS[interval_str]) % 7 + 1
    elsif interval_str =~ /^(\d+)(st|nd|rd|th)$/ # specific day of month, eg "1st" or "15th"
      day = $1.to_i
      delta = now.day >= day ?
        now.day - day :
        (now - last_month(day).not_nil!).days
      delta + 1
    elsif interval_str =~ /^(\d+)\/(\d+)$/ # specific day of year, eg "4/15" or "7/4"
      year, month, day = now.year, $1.to_i, $2.to_i
      year -= 1 if now.month < month ||
                   (now.month == month && now.day < day)
      (now - Time.local(year, month, day, now.hour, now.minute, now.second)).days + 1
    elsif interval_str =~ /^(\d+)d$/ # every number of days, eg "1d" or "14d"
      $1.to_i
    else
      raise Error.new("Unable to parse: #{interval_str}")
    end
  end

  private def last_month(day)
    last = now - 1.month
    [day, 30, 29, 28].each do |d|
      time = Time.local(last.year, last.month, d, now.hour, now.minute, now.second) rescue nil
      return time if time
    end
  end
end
