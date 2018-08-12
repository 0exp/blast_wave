# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::WhiteList::Matcher
    # @return [Object] #call-able object
    #
    # @api private
    # @since 0.1.0
    attr_reader :matcher

    # @param matcher [Object] #call-able object
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def initialize(matcher)
      @matcher = matcher
    end

    # @param request [Rack::Request]
    # @return [Boolean]
    #
    # @api private
    # @since 0.1.0
    def match?(request)
      !!matcher.call(request)
    end
  end
end
