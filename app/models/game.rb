class Game

  include Multiplex


  def initialize(user)
    @user = user
  end

  #####################################################################
  # stub/mock hooks

  def self.game_fifo_dir
    Dir.tmpdir
  end

  def self.backtick(command)
    `#{command}`
  end


  ####################################################################
  # daemon
  #
  #
  #  Good chapter on daemons:
  #
  #  Advanced Programming in the UNIX¨ Environment: Second Edition
  #  By: W. Richard Stevens; Stephen A. Rago
  #  Publisher: Addison-Wesley Professional
  #  Pub. Date: June 17, 2005
  #  Print ISBN-10: 0-201-43307-9
  #  Print ISBN-13: 978-0-201-43307-4

  def self.daemonize(command)
    fork do
      #reset umask so our current umask won't interfere with the daemon's business.
      File.umask 0000

      # become an orphan (without our sacrificial parent triggering on exit hooks)
      exit! if fork

      logger.info "Daemon spawned, pid #$$"

      # start our own process group, free from controlling terminal
      Process.setsid
      
      # go to root to prevent holding current directory in existence
      Dir.chdir "/"

      # close all inherited file handles.
      hard_file_limit = Process.getrlimit(Process::RLIMIT_NOFILE)[1]
      hard_file_limit = [1024, Process::RLIM_INFINITY].min
      (0...hard_file_limit).each do |f|
        begin
          File.for_fd(f).close
        rescue Errno::EBADF
          #ignore
        end
      end
      
      # reopen standard file handles pointed at nothingness.
      STDIN.reopen "/dev/null"
      STDOUT.reopen "/dev/null"
      STDERR.reopen "/dev/null"
      
      #become the requested command
      exec(command)
      
    end
  end

  #####################################################################
  # game management


  def fifo_name(direction)
    File.join(Game.game_fifo_dir, "#{direction}ward_fifo_#{@user.id}")
  end

  def downward_fifo_name
    fifo_name("down")
  end

  def upward_fifo_name
    fifo_name("up")
  end

  def unlink_fifos
    [downward_fifo_name, upward_fifo_name].each do |fifo_name|
      FileUtils.rm_f(fifo_name)
    end
  end

  def pid
    regexp = /^\s*(\d+)\s+(?!.*pty).*nethack(-console)? -u #{@user.login}\b/
    process_list = Game.backtick("ps -eo pid,command")
#    logger.info(process_list)
    found = regexp.match( process_list)
    if found
      pid = found[1].to_i
      logger.info "found game for #{@user.login}, pid #{pid}"
      return pid
    else
      logger.info "no game found for #{@user.login}"
      return nil
    end
  end

  def running?
    ! pid.nil?
  end

  def game_command
    %[#{::WEBHACK_CONFIG.nethack_path} -u "#{@user.login}"]
  end

  def start
    unless running?  

      unlink_fifos

      adapter = File.join(Rails.root, "app/models/pty_fifo_adapter.rb")
      process = "#{adapter} '#{game_command}' #{downward_fifo_name} #{upward_fifo_name}"
      command = "nohup #{process} > /dev/null &"

      Game.daemonize command

      until running? && File.exist?(downward_fifo_name) && File.exist?(upward_fifo_name)
        logger.info "waiting for game to start..."
        sleep 1
      end

   end
  end

  #############################################################
  # game interaction

  def move (input)
    outgoing_buffer = input.bytes.to_a
    File.open(downward_fifo_name, File::WRONLY | File::EXCL | File::SYNC | File::NONBLOCK) do |down|
      File.open(upward_fifo_name, File::RDONLY | File::EXCL | File::SYNC | File::NONBLOCK) do |up|
        write(down, outgoing_buffer)
        return read(up)
      end
    end
    incoming_buffer
  end

  def look
    File.open(downward_fifo_name, File::WRONLY | File::EXCL | File::SYNC | File::NONBLOCK) do
      File.open(upward_fifo_name, File::RDONLY | File::EXCL | File::SYNC | File::NONBLOCK) do |up|
        return read(up)
      end
    end
  end

  private

  def write(down, outgoing_buffer)
    outgoing_buffer.each do |c|
      while !IO.select(nil, [down], nil, 0.1)
        logger.error "File not ready on write."
      end
      down.syswrite(c.chr)
    end
  rescue Exception => e
    logger.error "Exception on write: #{e.inspect}"
  end


  def read(up)
    incoming_buffer = ""
    while IO.select([up], nil, nil, 0.1)
      incoming_buffer += up.sysread(max_buffer_size)
    end
    return incoming_buffer
  rescue Exception => e
    logger.error "Exception on read: #{e.inspect}"
    return ""
  end

end
