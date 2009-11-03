module Multiplex

  SELECT_READABLE_TIMEOUT_SECONDS = 10
  SELECT_WRITABLE_TIMEOUT_SECONDS = 0

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


  def select_readable(streams)
    select_result = IO.select(streams, nil, nil, SELECT_READABLE_TIMEOUT_SECONDS)
    readable_streams = select_result ? select_result[0] : []
    streams.each {|s| s.ready = readable_streams.include?(s)}
  end

  def select_writable(streams)
    select_result = IO.select(nil, streams, nil, SELECT_WRITABLE_TIMEOUT_SECONDS)
    writable_streams = select_result ? select_result[1] : []
    streams.each {|s| s.ready = writable_streams.include?(s)}
  end
  

end