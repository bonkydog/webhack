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

  def self.fork_and_exec(command)
    pid = fork do
      exec(command)
    end
    Process.detach(pid)
    pid
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

  def run
    return pid if  pid

    make_fifos

    game = %[/opt/local/bin/nethack -u "#{@user.login}"]
    adapter = File.join(Rails.root, "app/models/pty_fifo_adapter.rb")
    process = "#{adapter} '#{game}' #{downward_fifo_name} #{upward_fifo_name}"
    command = "nohup #{process} > /dev/null &"
    puts command

    Game.fork_and_exec command
    sleep 1
  end

  # SPIKE
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

  # SPIKE
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

  # SPIKE
  def read(incoming_buffer, up)
    while IO.select([up], nil, nil, 0.1)
      incoming_buffer += up.sysread(max_buffer_size)
    end
    return incoming_buffer
  rescue Exception => e
    logger.info e.inspect
  end


end
