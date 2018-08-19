# frozen_string_literal: true

module Rack
  module BlastWave::Utilities::Cache::Adapters
    # @api private
    # @since 0.1.0
    class ActiveSupportFileStore::Decrement < ActiveSupportNaiveStore::Decrement
      # @since 0.1.0
      include ActiveSupportFileStore::Fetching
    end
  end
end
