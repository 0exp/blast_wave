# frozen_string_literal: true

module Rack
  module BlastWave::Utilities::Cache::Adapters
    # @api private
    # @since 0.1.0
    class ActiveSupportMemoryStore::ReExpire < ActiveSupportNaiveStore::ReExpire
      # @since 0.1.0
      include ActiveSupportMemoryStore::Fetching
    end
  end
end
