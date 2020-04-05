require "../scron"
require "option_parser"

class Scron::Command
  SCHEDULE_FILE = File.join(ENV["HOME"], ".scron")
  HISTORY_FILE = File.join(ENV["HOME"], ".scrondb")
  LOG_FILE = File.join(ENV["HOME"], ".scronlog")
  EDITOR = ENV.fetch("editor", "vi")

  private getter args, io

  def initialize(@args : Array(String) = ARGV, @io : IO = STDOUT)
  end

  def run
    OptionParser.parse(args) do |parser|
      parser.banner = "Usage: scron [options]"
      parser.on("-e", "--edit", "edit jobs") { edit_jobs }
      parser.on("-r", "--run", "run jobs") { run_jobs }
      parser.on("-h", "--help", "show this help message") { print_help(parser) }
      parser.on("-v", "--version", "show version") { print_version }
    end
  rescue error : OptionParser::InvalidOption
    io.puts(error)
  end

  private def edit_jobs
    `#{EDITOR} #{SCHEDULE_FILE} < \`tty\` > \`tty\``
  end

  private def run_jobs
  end

  private def print_help(parser)
    io.puts(parser)
  end

  private def print_version
    io.puts(VERSION)
  end
end
