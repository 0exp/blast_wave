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
        def black_list_info
          env[ENVIRONMENT_KEY]
        end

        # @return [Boolean]
        #
        # @api public
        # @since 0.1.0
        def locked_by_black_list?
          black_list_info[:locked]
        end

        # @return [Array<String>]
        #
        # @api public
        # @since 0.1.0
        def triggered_black_list_filters
          black_list_info[:triggered_filters]
        end
      end
    end
  end
end
