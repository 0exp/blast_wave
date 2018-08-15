# frozen_string_literal: true

module Rack
  class BlastWave::BlackList
    # @api private
    # @since 0.1.0
    module Initializer
      # @return [Mutex]
      #
      # @api private
      # @since 0.1.0
      INITIALIZATION_LOCK = Mutex.new

      class << self
        # @param app [Object]
        # @return [void]
        #
        # @see extend_request_interface!
        #
        # @api private
        # @since 0.1.0
        def call(app)
          extend_request_interface!
        end

        private

        # @return [void]
        #
        # @see Rack::BlastWave::BlackList::Extensions::RequestInterface
        #
        # @api private
        # @since 0.1.0
        def extend_request_interface!
          INITIALIZATION_LOCK.synchronize do
            unless Rack::Request.include?(BlastWave::BlackList::Extensions::RequestInterface)
              Rack::Request.prepend(BlastWave::BlackList::Extensions::RequestInterface)
            end
          end
        end
      end
    end
  end
end
