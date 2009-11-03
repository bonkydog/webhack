require "rubygems"
require "pty"
require "logger"
require "activesupport"
require "pp"

class DuplexStreamAdapter
  
  SELECT_READABLE_TIMEOUT_SECONDS = 10
  SELECT_WRITABLE_TIMEOUT_SECONDS = 0

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

  def read_if_ready(source, buffer)
    return unless buffer.size < max_buffer_size
    return unless source.ready?
    incoming_character = source.sysread(1)[0]
    logger.debug "incoming_character=#{incoming_character}"
    buffer.push(incoming_character)
    source.ready = false
  rescue EOFError
    logger.debug "reached end of file"
    @eof = true
  end

  def write_if_ready(sink, buffer)
    return if buffer.empty? 
    return unless sink.ready?
    outgoing_character = buffer.shift
    logger.debug "outgoing_character=#{outgoing_character}"
    sink.syswrite( outgoing_character.chr)
    sink.ready = false
  end

  def select_readable
    select_result = IO.select(@incoming_streams, nil, nil, SELECT_READABLE_TIMEOUT_SECONDS)
    readable_streams = select_result ? select_result[0] : []
    @incoming_streams.each {|s| s.ready = readable_streams.include?(s)}
  end

  def select_writable
    select_result = IO.select(nil, @outgoing_streams, nil, SELECT_WRITABLE_TIMEOUT_SECONDS)
    writable_streams = select_result ? select_result[1] : []
    @outgoing_streams.each {|s| s.ready = writable_streams.include?(s)}
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

        select_readable

        read_if_ready(@coming_up, upward_buffer)
        read_if_ready(@coming_down, downward_buffer)

        select_writable

        write_if_ready(@going_up, upward_buffer)
        write_if_ready(@going_down, downward_buffer)

        return if @eof
      end

    end
  end

end