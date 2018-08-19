# frozen_string_literal: true

module Rack
  class BlastWave::WhiteList
    module Extensions
      # @api private
      # @since 0.1.0
      module RequestInterface
        # @return [Hash]
        #
        # @api public
        # @since 0.1.0
        def white_list_info
          env[ENVIRONMENT_KEY]
        end

        # @return [Boolean]
        #
        # @api public
        # @since 0.1.0
        def locked_by_white_list?
          white_list_info[:locked]
        end

        # @return [Array<String>]
        #
        # @api public
        # @since 0.1.0
        def triggered_white_list_filters
          white_list_info[:triggered_filters]
        end
      end
    end
  end
end
