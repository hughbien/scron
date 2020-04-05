require "../scron"

class Scron::History
  private getter now : Time
  private getter history : Hash(String, Time)

  def initialize(text : String, @now : Time)
    @history = Hash(String, Time).new
    text.split("\n").reject {|l| l =~ /^\s*$/}.each do |line|
      parts = line.split(/\s+/, 2)
      next if parts.size != 2

      timestamp, command = parts
      @history[command.strip] = Time.parse(timestamp, TIME_FORMAT, Time::Location.local)
    end
  end

  def has?(command)
    history.has_key?(command)
  end

  def [](command)
    history[command]
  end

  def touch(command)
    history[command] = now
  end

  def to_s(io)
    history.each do |command, time|
      io << "#{time.to_s(TIME_FORMAT)} #{command}\n"
    end
    io
  end

  def to_s
    to_s(IO::Memory.new).to_s
  end
end
