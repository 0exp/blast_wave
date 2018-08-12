# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::WhiteList::Checker
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize
      @matchers = BlastWave::WhiteList::MatcherList.new
    end

    # @param request [Rack::Request]
    # @option check_all [Boolean]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def check!(request, check_all: false)
      check_all ? all?(request) : any?(request)
    end

    # @param block [Proc]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def register(&block)
      matchers.register(BlastWave::WhiteList::Matcher.new(block))
    end

    private

    # @return [BlastWave::WhiteList::MatcherList]
    #
    # @api private
    # @since 0.1.0
    attr_reader :matchers

    # @param request [Rack::Request]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def any?(request)
      matchers.all?(request)
    end

    # @param request [Rack::Request]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def all?(request)
      matchers.any?(request)
    end
  end
end
