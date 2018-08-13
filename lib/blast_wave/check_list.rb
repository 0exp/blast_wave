# frozen_string_literal: true

module Rack
  # @api private
  # @since 0.1.0
  class BlastWave::CheckList < BlastWave::Middleware
    require_relative 'check_list/matcher'
    require_relative 'check_list/matcher_registry'
    require_relative 'check_list/fail_response'
    require_relative 'check_list/checkable'
    require_relative 'check_list/checker'
    require_relative 'check_list/builder'

    class << self
      # Creates a clone of the current middleware with it's own initial settings.
      #
      # @return [Class<BlastWave::CheckList>]
      #
      # @api public
      # @since 0.1.0
      def build
        Class.new(self)
      end

      # @param child_klass [Class]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def inherited(child_klass)
        BlastWave::CheckList::Builder.build(child_klass)
      end
    end
  end
end
