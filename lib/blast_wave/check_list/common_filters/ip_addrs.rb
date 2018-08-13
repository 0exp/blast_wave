# frozen_string_literal: true

module Rack
  module BlastWave::CheckList::CommonFilters
    # @api private
    # @since 0.1.0
    module IpAddrs
      class << self
        # @param addresses [Array<String>]
        # @return [BlastWave::CheckList::Filter]
        #
        # @api private
        # @since 0.1.0
        def build(*addresses)
          BlastWave::CheckList::Filter.new(FILTER_NAME, Matcher.new(*addresses))
        end
      end

      # @return [String]
      #
      # @api private
      # @since 0.1.0
      FILTER_NAME = 'ip_addrs'

      # @api private
      # @since 0.1.0
      class Matcher
        # @return [Array<IPAddr>]
        #
        # @api private
        # @since 0.1.0
        attr_reader :addresses

        # @param addresses [Array<String>]
        # @return [void]
        #
        # @api private
        # @since 0.1.0
        def initialize(*addresses)
          @addresses = addresses.map { |address| IPAddr.new(address) }
        end

        # @param request [Rack::Request]
        # @return [Boolean]
        #
        # @api private
        # @since 0.1.0
        def call(request)
          request_ip_addr = IPAddr.new(request.ip)
          addresses.any? { |address| address.include?(request_ip_addr) }
        end
      end
    end
  end
end
