# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::CheckList::Auditor
    # @api private
    # @since 0.1.0
    class Result
      # @return [Boolean]
      #
      # @api private
      # @since 0.1.0
      attr_accessor :locked

      # @return [Array<String>]
      #
      # @api private
      # @since 0.1.0
      attr_reader :triggered_filters

      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def initialize
        @locked = false
        @triggered_filters = []
      end
    end
  end
end
