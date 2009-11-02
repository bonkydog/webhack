require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DuplexStreamAdapter do

  before do
    @adapter = DuplexStreamAdapter.new(nil, nil, nil, nil)
  end

  describe "#read_if_ready" do
    before do
      @buffer = []
    end

    context "when stream is ready to be read" do

      before do
        @stream = mock!.sysread(1) {[?X.to_i]}.subject
        @adapter.instance_variable_set("@readable_streams", [@stream])
      end

      it "should read a character from the stream and push it onto the buffer" do
        @adapter.read_if_ready(@stream, @buffer)
        @buffer.first.should == "X"
      end

    end

    context "when stream is not ready to be read" do
      before do
        @adapter.instance_variable_set("@readable_streams", [@stream])
        @stream = dont_allow!.sysread(1) {[?X.to_i]}.subject
      end

      it "does nothing" do
        @adapter.read_if_ready(@stream, @buffer)
        @buffer == []
      end
    end

  end

  describe "#write_if_ready" do

  end

  describe "#select_readable" do

  end

  describe "#select_writable" do

  end

  describe "#wrap" do

  end

end