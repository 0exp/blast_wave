# frozen_string_literal: true

module Rack
  # @api public
  # @since 0.1.0
  BlastWave::CheckList = Class.new(BlastWave::Middleware)

  require_relative 'check_list/matcher'
  require_relative 'check_list/matcher_registry'
  require_relative 'check_list/fail_response'
  require_relative 'check_list/checkable'
  require_relative 'check_list/checker'
  require_relative 'check_list/builder'
end
