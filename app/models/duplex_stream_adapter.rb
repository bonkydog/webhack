require "rubygems"
require "logger"
require "activesupport"
require File.join(File.dirname(__FILE__), "../../lib/multiplex")

class DuplexStreamAdapter
  include Multiplex

  def initialize(coming_down, coming_up, going_down, going_up)
    
    @coming_down = coming_down
    @coming_up = coming_up
    @going_down = going_down
    @going_up = going_up

    @incoming_streams = [@coming_up, @coming_down]
    @outgoing_streams = [@going_up, @going_down]

  end

  def adapt
    @coming_up.sync = @going_down.sync = true
    upward_buffer = []
    downward_buffer = []

    i = 0
    exception = nil
    almost_done = false
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

      rescue Exception => e
        logger.info e.inspect
        exception = e
      ensure
        if almost_done
          raise exception
        end
        if exception
          almost_done = true
        end
      end


    end
  end

end