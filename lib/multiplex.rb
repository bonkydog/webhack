require "rubygems"
require "activesupport"

module Multiplex

  def self.included(host)
    host.instance_eval do
      cattr_accessor :logger
      self.logger = Logger.new(STDERR)
      self.logger.level = $DEBUG ? Logger::DEBUG : Logger::INFO

      cattr_accessor :max_buffer_size
      self.max_buffer_size = 2048
    end
  end

  SELECT_READABLE_TIMEOUT_SECONDS = 1
  SELECT_WRITABLE_TIMEOUT_SECONDS = 0
 
  class ::File
    attr_accessor :ready
    alias :ready? :ready
  end

  class ::FakeFile
    attr_accessor :ready
    alias :ready? :ready
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

  # SPIKE
  def read_all_if_ready(source)
    return unless source.ready?
    source.sysread(max_buffer_size)
  rescue EOFError
    logger.debug "reached end of file"
    @eof = true
  ensure
    source.ready = false
  end

  def select_readable(streams)
    select_result = IO.select(streams, nil, nil, SELECT_READABLE_TIMEOUT_SECONDS)
    readable_streams = select_result ? select_result[0] : []
    streams.each {|s| s.ready = readable_streams.include?(s)}
    return !!readable_streams
  end

  def select_writable(streams)
    select_result = IO.select(nil, streams, nil, SELECT_WRITABLE_TIMEOUT_SECONDS)
    writable_streams = select_result ? select_result[1] : []
    streams.each {|s| s.ready = writable_streams.include?(s)}
    return !!writable_streams
  end
  

end