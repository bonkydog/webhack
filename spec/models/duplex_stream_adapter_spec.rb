require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DuplexStreamAdapter do

  before do
    @adapter = DuplexStreamAdapter.new(:coming_down, :coming_up, :going_down, :going_up)
  end

  describe "#read_if_ready" do
    before do
      stub(@stream = Object.new).sysread(1) {[?X.to_i]}.subject
      @buffer = []
    end

    context "when stream is ready to be read" do

      before do
        @readable_streams = [@stream]
        @adapter.read_if_ready(@readable_streams, @stream, @buffer)
      end

      it "should read a character from the stream" do
        @stream.should have_received.sysread(1)
      end

      it "should write the character read from the stream to the end of the buffer" do
        @buffer.first.should == ?X
      end

    end

    context "when stream is not ready to be read" do
      before do
        @readable_streams = []
        @adapter.read_if_ready(@readable_streams, @stream, @buffer)
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
    before do
      stub(@stream = Object.new).syswrite
    end

    context "when stream is ready to be written to and the buffer has characters" do
      before do
        @buffer = [?x, ?y, ?z, ?z, ?y]
        @writable_streams = [@stream]
        @adapter.write_if_ready(@writable_streams, @stream, @buffer)
      end

      it "should remove the character from the front of the buffer" do
        @buffer.should == [?y, ?z, ?z, ?y]
      end

      it "should write the character at the front of the buffer to the stream" do
        @stream.should have_received.syswrite('x')
      end


    end

    context "when stream is not ready to be read" do
      before do
        @buffer = [?x, ?y, ?z, ?z, ?y]
        @writable_streams = []
        @adapter.write_if_ready(@writable_streams, @stream, @buffer)
      end


      it "should not change the buffer" do
        @buffer == []
      end

      it "should not attempt to write to the stream" do
        @stream.should_not have_received.syswrite(anything)
      end
    end

    context "when the buffer is empty" do
      before do
        @buffer = []
        @writable_streams = [@stream]
        @adapter.write_if_ready(@writable_streams, @stream, @buffer)
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
      it "should return a arry of readable streams" do
        stub(IO).select([:coming_up, :coming_down], nil, nil, 10) {[[:coming_up], [], []]}
        @adapter.select_readable.should == [:coming_up]
      end
    end

    context "when no stream is ready" do
      it "should return an empty array" do
        stub(IO).select([:coming_up, :coming_down], nil, nil, 10) {nil}
        @adapter.select_readable.should == []
      end

    end

  end

  describe "#select_writable" do

    context "when a stream is ready" do
      it "should return an array of writable streams" do
        stub(IO).select(nil, [:going_up, :going_down], nil, 0) {[[], [:going_down], []]}
        @adapter.select_writable.should == [:going_down]
      end
    end

    context "when no stream is ready" do
      it "should return an empty array" do
        stub(IO).select(nil, [:going_up, :going_down], nil, 0) {nil}
        @adapter.select_writable.should == []
      end
    end

  end

  describe "#adapt" do

  end

end