require "./scron/**"

module Scron
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
  TIME_FORMAT = "%Y-%m-%d.%H:%M"

  class Error < Exception; end
end
