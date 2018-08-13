# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::CheckList::FailResponse < Rack::Response
    # @return [Array<String>]
    #
    # @api private
    # @since 0.1.0
    DEFAULT_BODY = ["Forbidden\n"].freeze

    # @return [Hash]
    #
    # @api private
    # @since 0.1.0
    DEFAULT_HEADERS = { 'Content-Type' => 'text/plain' }.freeze

    # @return [Integer]
    #
    # @api private
    # @since 0.1.0
    DEFAULT_STATUS = 403

    class << self
      # @option status [Integer]
      # @option body [Array<String>]
      # @option headers [Hash]
      # @return [Rack::Response]
      #
      # @api private
      # @since 0.1.0
      def build(status: DEFAULT_STATUS, body: DEFAULT_BODY, headers: DEFAULT_HEADERS)
        new(body, status, headers)
      end
    end

    # @param body [Array<String>]
    # @param status [Integer]
    # @param header [Hash]
    # @return [void]
    #
    # @since 0.1.0
    # @api private
    def initialize(body = DEFAULT_BODY, status = DEFAULT_STATUS, header = DEFAULT_HEADERS)
      super
    end
  end
end
