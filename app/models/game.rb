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
  # fifo management


  def self.make_fifo(fifo_path)
    `mkfifo #{fifo_path}`
  end

  def fifo_name(direction)
    File.join(Game.game_fifo_dir, "#{direction}ward_fifo_#{@user.id}")
  end

  def downward_fifo_name
    fifo_name("down")
  end

  def upward_fifo_name
    fifo_name("up")
  end

  def make_fifos
    [downward_fifo_name, upward_fifo_name].each do |fifo_name|
      Game.make_fifo(fifo_name)
    end
  end

  def unlink_fifos
    [downward_fifo_name, upward_fifo_name].each do |fifo_name|
      FileUtils.rm(fifo_name)
    end
  end

  def pid
    regexp = /\s*(\d+).*pty_fifo_adapter.*-u "#{@user.login}".*/
    found = regexp.match(Game.backtick("ps -eo pid,command"))
    return nil unless found
    found[1].to_i
  end

  def running?
    ! pid.nil?
  end

  def start
    unless running?  

      make_fifos

      game = %[#{::WEBHACK_CONFIG.nethack_path} -u "#{@user.login}"]
      adapter = File.join(Rails.root, "app/models/pty_fifo_adapter.rb")
      process = "#{adapter} '#{game}' #{downward_fifo_name} #{upward_fifo_name}"
      command = "nohup #{process} > /dev/null &"

      Game.daemonize command

      sleep 0.1 until running?

   end
  end

  def move (input)
    incoming_buffer = ""
    outgoing_buffer = input.bytes.to_a
    File.open(downward_fifo_name, File::WRONLY | File::EXCL | File::SYNC | File::NONBLOCK) do |down|
      File.open(upward_fifo_name, File::RDONLY | File::EXCL | File::SYNC | File::NONBLOCK) do |up|
        write(down, outgoing_buffer)
        incoming_buffer = read(incoming_buffer, up)
      end
    end
    incoming_buffer
  end

  def look
    incoming_buffer = ""
    File.open(downward_fifo_name, File::WRONLY | File::EXCL | File::SYNC | File::NONBLOCK) do
      File.open(upward_fifo_name, File::RDONLY | File::EXCL | File::SYNC | File::NONBLOCK) do |up|
        incoming_buffer = read(incoming_buffer, up)
      end
    end
    incoming_buffer
  end

  private

  def write(down, outgoing_buffer)
    outgoing_buffer.each do |c|
      while !IO.select(nil, [down], nil, 0.1)
        puts "whuuut?"
      end
      down.syswrite(c.chr)
    end
  rescue Exception => e
    logger.info e.inspect
  end


  def read(incoming_buffer, up)
    while IO.select([up], nil, nil, 0.1)
      incoming_buffer += up.sysread(max_buffer_size)
    end
    return incoming_buffer
  rescue Exception => e
    logger.info e.inspect
  end


end
