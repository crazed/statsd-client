require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Statsd::Client do

  describe "being initialized" do

    describe "without any parameters" do
      subject { Statsd::Client.new }
      it { subject.host.should == 'localhost' }
      it { subject.port.should == 8125 }
    end

    describe "with a host and port parameter" do
      subject { Statsd::Client.new('example.com', 5555) }
      it { subject.host.should == 'example.com' }
      it { subject.port.should == 5555 }
    end

  end

  describe "sending a timing statistic" do

    subject { Statsd::Client.new }
    before(:each) do
      @udp_socket = mock(UDPSocket, :close => true)
      UDPSocket.should_receive(:new).and_return(@udp_socket)
    end

    describe "without a sample rate" do

      after(:each) { subject.timing('test', 350) }

      it "should send a packet with the message 'test:350|ms'" do
        @udp_socket.should_receive(:send).with("test:350|ms", 0, subject.host, subject.port)
      end

    end

    describe "with sample rate of 0.5 (where it has been sampled for sending)" do

      before(:each) { Kernel.should_receive(:rand).and_return(0.1) }
      after(:each) { subject.timing('test', 350, 0.5) }

      it "should send a packet with the message 'test:350|ms|@0.5" do
        @udp_socket.should_receive(:send).with("test:350|ms|@0.5", 0, subject.host, subject.port)
      end

    end

  end

  describe "incrementing a statistic" do

    subject { Statsd::Client.new }
    before(:each) do
      @udp_socket = mock(UDPSocket, :close => true)
      UDPSocket.should_receive(:new).and_return(@udp_socket)
    end

    describe "without a sample rate" do

      after(:each) { subject.increment('test') }

      it "should send a packet with the message 'test:1|c'" do
        @udp_socket.should_receive(:send).with("test:1|c", 0, subject.host, subject.port)
      end

    end

    describe "with sample rate of 0.5 (where it has been sampled for sending)" do

      before(:each) { Kernel.should_receive(:rand).and_return(0.1) }
      after(:each) { subject.increment('test', 0.5) }

      it "should send a packet with the message 'test:1|c|@0.5" do
        @udp_socket.should_receive(:send).with("test:1|c|@0.5", 0, subject.host, subject.port)
      end

    end

  end

  describe "decrementing a statistic" do

    subject { Statsd::Client.new }
    before(:each) do
      @udp_socket = mock(UDPSocket, :close => true)
      UDPSocket.should_receive(:new).and_return(@udp_socket)
    end

    describe "without a sample rate" do

      after(:each) { subject.decrement('test') }

      it "should send a packet with the message 'test:-1|c'" do
        @udp_socket.should_receive(:send).with("test:-1|c", 0, subject.host, subject.port)
      end

    end

    describe "with sample rate of 0.5 (where it has been sampled for sending)" do

      before(:each) { Kernel.should_receive(:rand).and_return(0.1) }
      after(:each) { subject.decrement('test', 0.5) }

      it "should send a packet with the message 'test:-1|c|@0.5" do
        @udp_socket.should_receive(:send).with("test:-1|c|@0.5", 0, subject.host, subject.port)
      end

    end

  end

  describe "updating many statistics" do

    subject { Statsd::Client.new }
    before(:each) do
      @udp_socket = mock(UDPSocket, :close => true)
      UDPSocket.should_receive(:new).and_return(@udp_socket)
    end

    describe "without a sample rate" do

      after(:each) { subject.update_stats(['test.1', 'test.2'], 1) }

      it "should send two packets'" do
        @udp_socket.should_receive(:send).with("test.1:1|c", 0, subject.host, subject.port).once
        @udp_socket.should_receive(:send).with("test.2:1|c", 0, subject.host, subject.port).once
      end

    end

    describe "with sample rate of 0.5 (where it has been sampled for sending)" do

      before(:each) { Kernel.should_receive(:rand).and_return(0.1) }
      after(:each) { subject.update_stats(['test.1', 'test.2'], 1, 0.5) }

      it "should send a two packets" do
        @udp_socket.should_receive(:send).with("test.1:1|c|@0.5", 0, subject.host, subject.port).once
        @udp_socket.should_receive(:send).with("test.2:1|c|@0.5", 0, subject.host, subject.port).once
      end

    end

  end

end

