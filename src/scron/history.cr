require "../scron"

# Keeps track of the last time a command ran. When a command runs, update the timestamp with
# `Scron::History#touch`. The entire history database can be written to a string with
# `Scron::History#to_s`.
class Scron::History
  private getter now : Time
  private getter history : Hash(String, Time)

  # Instantiates a new history. Example history format looks like:
  # ```
  # 2020-01-01.06:00 /path/to/command1
  # 2020-02-05.22:15 /path/to/command2 arg1 arg2
  # ```
  #
  # Example usage:
  # ```
  # Scron::History.new("2020-01-01.06:00 /path/to/command1")
  # ```
  def initialize(text : String, @now : Time)
    @history = Hash(String, Time).new
    text.split("\n").reject {|l| l =~ /^\s*$/}.each do |line|
      parts = line.split(/\s+/, 2)
      next if parts.size != 2

      timestamp, command = parts
      @history[command.strip] = Time.parse(timestamp, TIME_FORMAT, Time::Location.local)
    end
  end

  # Returns true if this command ever ran at least once.
  def has?(command)
    history.has_key?(command)
  end

  # Returns Time for the last time this command ran. Raises error if it never ran.
  def [](command)
    history[command]
  rescue KeyError
    raise Error.new("Command never ran: #{command}")
  end

  # Sets timestamp to current time. This method should be called whenever the command runs.
  def touch(command)
    history[command] = now
  end

  # Returns history database as string via string builder pattern to save memory.
  def to_s(io)
    history.each do |command, time|
      io << "#{time.to_s(TIME_FORMAT)} #{command}\n"
    end
    io
  end

  # Returns history database as string, meant to be saved to ~/.scrondb file.
  def to_s
    to_s(IO::Memory.new).to_s
  end
end
