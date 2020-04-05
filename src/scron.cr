require "./scron/**"

module Scron
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
end
