require "rubygems"
require "logger"
require "activesupport"

class DuplexStreamAdapter
  include Multiplex

  cattr_accessor :logger
  self.logger = Logger.new(STDERR)
  self.logger.level = $DEBUG ? Logger::DEBUG : Logger::INFO

  attr_accessor :max_buffer_size

  def initialize(coming_down, coming_up, going_down, going_up)
    
    @coming_down = coming_down
    @coming_up = coming_up
    @going_down = going_down
    @going_up = going_up

    [@coming_down, @coming_up, @going_down, @going_up].each {|s| add_ready_attribute_to(s)}

    @incoming_streams = [@coming_up, @coming_down]
    @outgoing_streams = [@going_up, @going_down]

    @max_buffer_size = 2048
  end

  def add_ready_attribute_to(stream)
    stream.instance_eval  do
      @ready = false
      class << self
        attr_accessor :ready
        alias :ready? :ready 
      end
    end
  end

  def adapt
    @coming_up.sync = @going_down.sync = true
    upward_buffer = []
    downward_buffer = []

    @eof = false
    i = 0
    while true
      begin
        i += 1
        logger.debug "loop #{i}"

        select_readable(@incoming_streams)

        read_if_ready(@coming_up, upward_buffer)
        read_if_ready(@coming_down, downward_buffer)

        select_writable(@outgoing_streams)

        write_if_ready(@going_up, upward_buffer)
        write_if_ready(@going_down, downward_buffer)

        return if @eof
      end

    end
  end

end