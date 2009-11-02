#!/usr/bin/env ruby


DEBUGGING_WRAPPER = true

# first, set up the fifos:

# mkfifo /tmp/wumpus_listen
# mkfifo /tmp/wumpus_speak

# in the controller window, say:
# save_state=$(stty -g); stty raw; cat -u > /tmp/downward; stty "$save_state"

# in the view window, say:
# save_state=$(stty -g); stty raw; cat -u /tmp/upward; stty "$save_state"

# in the model window, say:
# script/game/fifo_pty_wrapper_spike.rb /opt/local/bin/wumpus  /tmp/downward /tmp/upward


# IO variables are named imagining the controlling process on top, this wrapper in the middle, and the
# controlled process on the bottom.


require "pty"

def read_if_ready(source_fifo, ready_read_streams, buffer)
  if ready_read_streams.include?(source_fifo)
    coming_up_character = source_fifo.sysread(1)[0].chr
    $stderr.puts("coming_up_character=#{coming_up_character}") if DEBUGGING_WRAPPER
    buffer.push( coming_up_character)
  end
end

def write_if_ready(destination_fifo, ready_streams, buffer)
  return if buffer.empty?
  return unless ready_streams && ready_streams.include?(destination_fifo)
  going_up_character = buffer.shift
  $stderr.puts("going_up_character=#{going_up_character}") if DEBUGGING_WRAPPER
  destination_fifo.syswrite( going_up_character)
end

def spike(command, downward_fifo_path, upward_fifo_path)

  coming_down = File.open(downward_fifo_path, File::RDONLY | File::EXCL | File::SYNC)
  going_up = File.open(upward_fifo_path, File::WRONLY | File::EXCL | File::SYNC)
  
  PTY.spawn(command) do | coming_up, going_down, pid|
    coming_up.sync = going_down.sync = true
    upward_buffer = []
    downward_buffer = []

    i = 0
    while true
      begin
        i += 1
        puts "loop #{i}"  if DEBUGGING_WRAPPER

        select_result = IO.select([coming_up, coming_down], nil, nil, 10)
        ready_streams = select_result ? select_result.flatten : []

        read_if_ready(coming_up, ready_streams, upward_buffer)
        read_if_ready(coming_down, ready_streams, downward_buffer)

        select_result = IO.select(nil, [going_up, going_down], nil, 0)
        ready_streams = select_result ? select_result.flatten : []

        write_if_ready(going_up, ready_streams, upward_buffer)
        write_if_ready(going_down, ready_streams, downward_buffer)

      rescue EOFError
        # ignore
      end
    end
  end
end

if File.basename($0) == File.basename(__FILE__)
  unless ARGV.size == 3
    echo "usage: #$0 command downward_fifo_path upward_fifo_path"
    exit 1
  end   
  spike(*ARGV)
end