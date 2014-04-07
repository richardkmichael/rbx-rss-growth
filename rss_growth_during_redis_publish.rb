require 'bundler'
Bundler.setup

require 'pry'
require 'redis'
require 'hiredis'
require 'celluloid'
require 'celluloid/io'  # Unclear if this is required, or if Celluloid will handle it.
require 'celluloid/redis'
require 'celluloid/autostart'

class Leaky
  include Celluloid
  # include Celluloid::IO

  attr_reader :driver, :redis

  def initialize
    @driver = :celluloid
    # @driver = :hiredis

    # @redis = ::Redis.new url: 'redis://localhost:6379', driver: @driver
    @redis = ::Redis.new path: '/tmp/redis.sock',       driver: @driver

    @publish_count = 0
  end

  def publish
    @redis.publish "test", @publish_count += 1
    # @redis.publish "test", 'a' # RSS growth is independent of message length 
  end
end

require 'optparse'
option_parser = OptionParser.new do |opts|
  opts.on('-n X', Integer) { |v| $number_of_iterations = v }
  opts.on('-s X', Float)   { |v| $sleep_time = v }
end
option_parser.parse ARGV

leaky = Leaky.new

puts <<-RUN_INFO.lines.map &:lstrip
        Ruby: #{RUBY_DESCRIPTION}
        Publishing #{$number_of_iterations} times with sleep #{$sleep_time ? $sleep_time : '0' } on #{leaky.redis.inspect}, using the #{leaky.driver} driver.
        (Confirm loaded Redis drivers: #{Redis::Connection.drivers})
        ----------------------------------------------------------------------------------
        RUN_INFO

puts "Linux copy/paste: 'watch -n 0.2 cat /proc/#{Process.pid}/status'"

start_delay = 3
puts "Starting in #{start_delay}s"
sleep start_delay

$number_of_iterations.times do
  leaky.publish
  sleep $sleep_time if $sleep_time
end
