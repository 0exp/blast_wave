# frozen_string_literal: true

module Rack
  class BlastWave::RequestId
    module Extensions
      # @api private
      # @since 0.1.0
      module RequestInterface
        # @return [String]
        #
        # @api public
        # @since 0.1.0
        def request_id
          env[REQUEST_ID_ENV_KEY]
        end
      end
    end
  end
end
