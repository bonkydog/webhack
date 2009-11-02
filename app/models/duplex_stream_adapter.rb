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
  end

  def read_if_ready(readable_streams, source, buffer)
    if readable_streams.include?(source)
      coming_up_character = source.sysread(1)[0]
      logger.debug "coming_up_character=#{coming_up_character}"
      buffer.push( coming_up_character)
    end
  end

  def write_if_ready(writable_streams, sink, buffer)
    return if buffer.empty? 
    return unless writable_streams.include?(sink)
    going_up_character = buffer.shift
    logger.debug "going_up_character=#{going_up_character}"
    sink.syswrite( going_up_character.chr)
  end

  def select_readable
    select_result = IO.select([@coming_up, @coming_down], nil, nil, SELECT_READABLE_TIMEOUT_SECONDS)
    select_result ? select_result.flatten : []
  end

  def select_writable
    select_result = IO.select(nil, [@going_up, @going_down], nil, SELECT_WRITABLE_TIMEOUT_SECONDS)
    select_result ? select_result.flatten : []
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

        read_if_ready(readable_streams, @coming_up, upward_buffer)
        read_if_ready(readable_streams, @coming_down, downward_buffer)

        writable_streams = select_writable

        write_if_ready(writable_streams, @going_up, upward_buffer)
        write_if_ready(writable_streams, @going_down, downward_buffer)

      rescue EOFError => e
        logger.debug "Ignoring EOF: #{e.inspect}"
      end

    end
  end

end