# Wraps a single line in the schedule file. Made up of two parts, the interval and the command. 
# Determines if a command is overdue and needs to be run.
class Scron::Schedule
  getter command : String
  getter interval : String

  def initialize(line : String)
    parts = line.strip.split(/\s+/, 2)
    raise Error.new("Unable to parse line: #{line}") if parts.size != 2
    @interval, @command = parts
  end

  def run
  end

  # Given the text of a schedule file, parses it and returns an Array of Schedules.
  # Lines prefixed with `#` are ignored as a comment.
  # Empty lines are also ignored.
  def self.parse(text : String) : Array(Scron::Schedule)
    text.split("\n").
      reject { |line| self.is_empty?(line) || self.is_comment?(line) }.
      map { |line| self.new(line) }
  end

  private def self.is_empty?(line : String)
    line =~ /^\s*#/
  end

  private def self.is_comment?(line : String)
    line =~ /^\s*$/
  end
end
