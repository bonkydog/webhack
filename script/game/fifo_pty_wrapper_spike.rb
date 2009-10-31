#!/usr/bin/env ruby


# first, set up the fifos:

# mkfifo /tmp/wumpus_listen
# mkfifo /tmp/wumpus_speak

# in the controller window, say:
# save_state=$(stty -g); stty raw; cat -u > /tmp/wumpus_listen; stty "$save_state"

# in the view window, say:
# save_state=$(stty -g); stty raw; cat -u /tmp/wumpus_speak; stty "$save_state"

# in the model window, say:
# ./fifo_pty_wrapper_spike.rb /opt/local/bin/wumpus


# IO variables are named imagining the controlling process on top, this wrapper in the middle, and the
# controlled process on the bottom.


require "pty"

def spike(command)

  coming_down = File.open("/tmp/wumpus_listen", File::RDONLY | File::EXCL | File::SYNC)
  going_up = File.open("/tmp/wumpus_speak", File::WRONLY | File::EXCL | File::SYNC)
  
  PTY.spawn(command) do | coming_up, going_down, pid|
    coming_up.sync = going_down.sync = true
    downward_buffer = []
    upward_buffer = []

    i = 0
    while true
      begin
        i += 1
        puts "loop #{i}"
        select_result = IO.select([coming_up, coming_down], nil, nil, 10)
        next if select_result.nil?

        puts "X"

        ready_read_streams = select_result[0]

        if ready_read_streams.include?(coming_up)
          downward_buffer.push(coming_up.sysread(1)[0].chr)
        end

        if ready_read_streams.include?(coming_down)
          upward_buffer.push(coming_down.sysread(1)[0].chr)
        end

        if !upward_buffer.empty?
          select_result = IO.select(nil, [going_down], nil, 0)
          unless select_result.nil?
            ready_write_streams = select_result[1]

            unless ready_write_streams.empty?
              going_down.syswrite(upward_buffer.shift)
            end
          end
        end

        if !downward_buffer.empty?
          select_result = IO.select(nil, [going_up], nil, 0)
          unless select_result.nil?
            ready_write_streams = select_result[1]

            unless ready_write_streams.empty?
              going_up.syswrite(downward_buffer.shift)
            end
          end
        end

        if !downward_buffer.empty? && ! IO.select([], [going_up], nil, 0)[1].empty?
          going_up.syswrite(downward_buffer.shift)
        end
      rescue EOFError
        # ignore
      end
    end
  end
end

if File.basename($0) == File.basename(__FILE__)
  spike(ARGV[0])
end