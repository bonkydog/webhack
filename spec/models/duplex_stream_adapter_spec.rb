require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Pty
  class ChildExited < Exception; end
end

describe DuplexStreamAdapter do

  include Multiplex

  before do
    @coming_down = FakeFile.new
    @coming_up = FakeFile.new
    @going_down = FakeFile.new
    @going_up = FakeFile.new
    [@coming_down, @coming_up, @going_down, @going_up].each {|s| stub(s).sync=(anything)}
    @adapter = DuplexStreamAdapter.new(@coming_down, @coming_up, @going_down, @going_up)
  end

  describe "#adapt" do
    it "should read from the incoming streams and write to the outgoing streams" do
      downward_transmission = 'hello, down there!'.bytes.to_a
      downward_receipt = []

      upward_transmission =   'hello, up there!!!'.bytes.to_a
      upward_receipt = []

      upward_cursor = 0
      downward_cursor = 0

      stub(IO).select([@coming_up, @coming_down], nil, nil, 1) do
        [[@coming_up, @coming_down], [], []]
      end

      stub(IO).select(nil, [@going_up, @going_down], nil, 0) do
        [[], [@going_up, @going_down], []]
      end

      stub(@coming_down).sysread(1) do
        raise Pty::ChildExited unless downward_cursor < downward_transmission.size # otherwise it will run forever.
        x = returning downward_transmission[downward_cursor] do
          downward_cursor += 1
        end
        [x]
      end

      stub(@coming_up).sysread(1) do
        raise Pty::ChildExited unless downward_cursor < downward_transmission.size # otherwise it will run forever.
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

      lambda{ @adapter.adapt }.should raise_error(Pty::ChildExited)

      downward_receipt.should == downward_transmission.map(&:chr)
    end

  end

end