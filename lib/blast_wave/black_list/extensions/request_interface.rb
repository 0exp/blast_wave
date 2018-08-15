# frozen_string_literal: true

module Rack
  class BlastWave::BlackList
    module Extensions
      # @api private
      # @since 0.1.0
      module RequestInterface
        # @return [Hash]
        #
        # @api public
        # @since 0.1.0
        def blacklist_info
          env[ENVIRONMENT_KEY]
        end

        # @return [Boolean]
        #
        # @api public
        # @since 0.1.0
        def locked_by_blacklist?
          blacklist_info[:locked]
        end

        # @return [Array<String>]
        #
        # @api public
        # @since 0.1.0
        def triggered_blacklist_filters
          blacklist_info[:triggered_filters]
        end
      end
    end
  end
end
