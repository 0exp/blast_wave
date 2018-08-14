# frozen_string_literal: true

module Rack
  # @api public
  # @since 0.1.0
  class BlastWave::BlackList < BlastWave::CheckList
    # @param env [Hash]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def call(env)
      case
      when no_filters?
        super
      when check!(env) && lock_requests?
        generate_fail_response!
      else
        super
      end
    end
  end
end
