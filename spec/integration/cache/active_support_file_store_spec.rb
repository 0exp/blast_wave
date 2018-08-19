# frozen_string_literal: true

# rubocop:disable RSpec/Focus
if SpecSupport::Testing.test_as_file_store_cache?
  require_relative 'cache_utility_common_behaviour_examples'

  describe 'Cache utility => Storage: Redis', :focus do
    driver = SpecSupport::Cache::ActiveSupportFileStore.connect

    it_behaves_like 'Cache utility => Common behaviour' do
      let!(:cache_storage) { Rack::BlastWave::Utilities::Cache.build(driver) }
    end
  end
end
# rubocop:enable RSpec/Focus
