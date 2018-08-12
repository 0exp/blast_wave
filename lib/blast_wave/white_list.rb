# frozen_string_literal: true

module Rack
  # @api public
  # @since 0.1.0
  class BlastWave::WhiteList < BlastWave::Middleware
    require_relative 'white_list/matcher'
    require_relative 'white_list/matcher_registry'
    require_relative 'white_list/checker'
    require_relative 'white_list/fail_response'
    require_relative 'white_list/checkable'
    require_relative 'white_list/builder'

    Builder.build(self)
  end
end
