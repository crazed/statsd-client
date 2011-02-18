# @author Tom Taylor
require 'socket'

module Statsd
  class Client

    attr_reader :host, :port

    # Initializes a Statsd client.
    #
    # @param [String] host
    # @param [Integer] port
    def initialize(host = 'localhost', port = 8125)
      @host, @port = host, port
    end

    # Sends timing statistics.
    #
    # @param [Array, String] stats name of statistic(s) being updated
    # @param [Integer] time in miliseconds
    # @param [Integer, Float] sample_rate
    def timing(stats, time, sample_rate = 1)
      data = "#{time}|ms"
      update_stats(stats, data, sample_rate)
    end

    # Increments a counter
    #
    # @param [Array, String] stats name of statistic(s) being updated
    # @param [Integer, Float] sample_rate
    def increment(stats, sample_rate = 1)
      update_stats(stats, 1, sample_rate)
    end

    # Decrements a counter
    #
    # @param [Array, String] stats name of statistic(s) being updated
    # @param [Integer, Float] sample_rate
    def decrement(stats, sample_rate = 1)
      update_stats(stats, -1, sample_rate)
    end

    # Updates one or more counters by an arbitrary amount
    #
    # @param [Array, String] stats name of statistic(s) being updated
    # @param [Integer, Float] delta
    # @param [Integer, Float] sample_rate
    def update_stats(stats, delta = 1, sample_rate = 1)
      stats = [stats] unless stats.kind_of?(Array)

      data = {}

      delta = delta.to_s
      stats.each do |stat|
        # if it's got a |ms in it, we know it's a timing stat, so don't append
        # the |c.
        data[stat] = delta.include?('|ms') ? delta : "#{delta}|c"
      end

      send(data, sample_rate)
    end

    private

    def send(data, sample_rate = 1)
      sampled_data = {}
      
      if sample_rate < 1
        if Kernel.rand <= sample_rate
          data.each do |k,v|
            sampled_data[k] = "#{v}|@#{sample_rate}"
          end
        end
      else
        sampled_data = data
      end

      socket = UDPSocket.new

      begin
        sampled_data.each do |k,v|
          message = [k,v].join(':')
          socket.send(message, 0, self.host, self.port)
        end
      rescue Exception => e
        puts "Unexpected error: #{e}"
      ensure
        socket.close
      end
    end

  end
end
