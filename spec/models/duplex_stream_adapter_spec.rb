require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DuplexStreamAdapter do

  before do
    @coming_down = Object.new
    @coming_up = Object.new
    @going_down = Object.new
    @going_up = Object.new
    [@coming_down, @coming_up, @going_down, @going_up].each {|s| stub(s).sync=(anything)}
    @adapter = DuplexStreamAdapter.new(@coming_down, @coming_up, @going_down, @going_up)
  end

  describe "#add_ready_attribute" do
    before do
      @stream = Object.new
      @adapter.add_ready_attribute_to @stream
    end

    it "should add a ready attribute to an object" do
      @stream.ready = true
      @stream.should be_ready
    end

    it "should not add a ready attribute to the object's class" do
      Object.new.should_not respond_to(:ready)
    end
  end

  describe "io" do
    before do
      @stream = Object.new
      @adapter.add_ready_attribute_to(@stream)
      stub(@stream).sysread(1) {[?X.to_i]}.subject
      stub(@stream).syswrite

      @buffer = []
    end


    describe "#read_if_ready" do

      context "when stream is ready to be read" do
        before do
          @stream.ready = true
        end

        context "when buffer is not full" do
          before do
            @adapter.read_if_ready(@stream, @buffer)
          end

          it "should read a character from the stream" do
            @stream.should have_received.sysread(1)
          end

          it "should append the character read from the stream to the buffer" do
            @buffer.first.should == ?X
          end

          it "should mark the stream unready" do
            @stream.should_not be_ready
          end
        end

        context "when buffer is full" do
          before do
            @buffer = [?f, ?u, ?l, ?l]
            @adapter.max_buffer_size = 4
            @adapter.read_if_ready(@stream, @buffer)
          end

          it "should not change the buffer" do
            @buffer == []
          end

          it "should not attempt to read from the stream" do
            @stream.should_not have_received.sysread(anything)
          end
        end

      end

      context "when stream is not ready to be read" do
        before do
          @adapter.read_if_ready(@stream, @buffer)
        end

        it "should not change the buffer" do
          @buffer == []
        end

        it "should not attempt to read from the stream" do
          @stream.should_not have_received.sysread(anything)
        end
      end
    end

    describe "#write_if_ready" do

      context "when  the buffer has characters" do
        before do
          @buffer = [?x, ?y, ?z, ?z, ?y]
        end

        context "when stream is ready to be written" do
          before do
            @stream.ready = true
            @adapter.write_if_ready(@stream, @buffer)
          end


          it "should remove the character from the front of the buffer" do
            @buffer.should == [?y, ?z, ?z, ?y]
          end

          it "should write the character at the front of the buffer to the stream" do
            @stream.should have_received.syswrite('x')
          end

          it "should mark the stream unready" do
            @stream.should_not be_ready
          end

        end

        context "when stream is not ready to write" do
          before do
            @buffer = [?x, ?y, ?z, ?z, ?y]
            @adapter.write_if_ready(@stream, @buffer)
          end

          it "should not change the buffer" do
            @buffer == []
          end

          it "should not attempt to write to the stream" do
            @stream.should_not have_received.syswrite(anything)
          end
        end
      end


      context "when the buffer is empty" do
        before do
          @stream.ready = true
          @adapter.write_if_ready(@stream, @buffer)
        end

        it "should not change the buffer" do
          @buffer == []
        end

        it "should not attempt to write to the stream" do
          @stream.should_not have_received.syswrite(anything)
        end
      end

    end

    describe "#select_readable" do

      context "when a stream is ready" do
        before do
          stub(IO).select([@coming_up, @coming_down], nil, nil, 10) {[[@coming_up], [], []]} # timeout should be 10sec
          @adapter.select_readable([@coming_up, @coming_down])
        end

        it "should return mark the readable streams ready" do
          @coming_up.should be_ready
        end

        it "should return not mark the unreadable streams ready" do
          @coming_down.should_not be_ready
        end
      end

      context "when no stream is ready" do
        before do
          stub(IO).select([@coming_up, @coming_down], nil, nil, 10) {nil} # timeout should be 10 seconds
          @adapter.select_readable([@coming_up, @coming_down])
        end

        it "should return not mark the unreadable streams ready" do
          @coming_up.should_not be_ready
          @coming_down.should_not be_ready
        end
      end

    end

    describe "#select_writable" do

      context "when a stream is ready" do
        before do
          stub(IO).select(nil, [@going_up, @going_down], nil, 0) {[[], [@going_up], []]} # timeout should be 0 seconds
          @adapter.select_writable([@going_up, @going_down])
        end

        it "should return mark the writable streams ready" do
          @going_up.should be_ready
        end

        it "should return not mark the unwritable streams ready" do
          @going_down.should_not be_ready
        end
      end

      context "when no stream is ready" do
        before do
          stub(IO).select(nil, [@going_up, @going_down], nil, 0) {nil} # timeout should be 0 seconds
          @adapter.select_writable([@going_up, @going_down])
        end

        it "should return not mark the unwritable streams ready" do
          @going_up.should_not be_ready
          @going_down.should_not be_ready
        end
      end

    end
  end

  describe "#adapt" do
    it "should read from the incoming streams and write to the outgoing streams" do
      downward_transmission = 'hello, down there!'.bytes.to_a
      downward_receipt = []

      upward_transmission =   'hello, up there!!!'.bytes.to_a
      upward_receipt = []

      upward_cursor = 0
      downward_cursor = 0

      stub(IO).select([@coming_up, @coming_down], nil, nil, 10) do
        [[@coming_up, @coming_down], [], []]
      end

      stub(IO).select(nil, [@going_up, @going_down], nil, 0) do
        [[], [@going_up, @going_down], []]
      end

      stub(@coming_down).sysread(1) do
        raise EOFError unless downward_cursor < downward_transmission.size
        x = returning downward_transmission[downward_cursor] do
          downward_cursor += 1
        end
        [x]
      end

      stub(@coming_up).sysread(1) do
        raise EOFError unless upward_cursor < upward_transmission.size
        x = returning upward_transmission[upward_cursor] do
          upward_cursor += 1
        end
        [x]
      end


      stub(@going_down).syswrite do |x|
        downward_receipt << x
      end

      stub(@going_up).syswrite do |x|
        upward_receipt << x
      end

      @adapter.adapt

      downward_receipt.should == downward_transmission.map(&:chr)
    end

  end

end