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
   
  def initialize(coming_down, coming_up, going_down, going_up)
    
    @coming_down = coming_down
    @coming_up = coming_up
    @going_down = going_down
    @going_up = going_up

    [@coming_down, @coming_up, @going_down, @going_up].each {|s| add_ready_attribute_to(s)}

    @incoming_streams = [@coming_up, @coming_down]
    @outgoing_streams = [@going_up, @going_down]
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
    return unless source.ready?
    coming_up_character = source.sysread(1)[0]
    logger.debug "coming_up_character=#{coming_up_character}"
    buffer.push( coming_up_character)
  end

  def write_if_ready(sink, buffer)
    return if buffer.empty? 
    return unless sink.ready?
    going_up_character = buffer.shift
    logger.debug "going_up_character=#{going_up_character}"
    sink.syswrite( going_up_character.chr)
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

    i = 0
    while true
      begin
        i += 1
        logger.debug "loop #{i}"

        readable_streams = select_readable

        read_if_ready(@coming_up, upward_buffer)
        read_if_ready(@coming_down, downward_buffer)

        writable_streams = select_writable

        write_if_ready(@going_up, upward_buffer)
        write_if_ready(@going_down, downward_buffer)

      rescue EOFError => e
        logger.debug "Ignoring EOF: #{e.inspect}"
      end

    end
  end

end