# frozen_string_literal: true

RSpec.describe 'Rack::BlastWave::RequestId Middleware' do
  before do
    # NOTE: inject fake request id randomizer
    Rack::BlastWave::RequestId.configure do |conf|
      fake_id_values = %w[1 2 3 4 5 6 7 8].cycle
      conf.id_randomizer = -> { fake_id_values.next }
    end
  end

  let(:app) { build_fake_rack_app(Rack::BlastWave::RequestId) }

  describe 'request interface' do
    specify 'request id' do
      make_request(:get, '/')

      expect(last_request.env.keys).to include('rack.blastwave.request_id')
      expect(last_request).to respond_to(:request_id)
      expect(last_request.env['rack.blastwave.request_id']).to eq(last_request.request_id)
    end
  end

  describe 'request id randomization' do
    specify 'each request gets his own request_id' do
      request_results = make_request_series(3, :get, '/')

      # NOTE: 3 unique request ids
      expect(request_results.map(&:request).map(&:request_id).uniq.count).to eq(3)

      expect(request_results[0].request.env['rack.blastwave.request_id']).to eq('1')
      expect(request_results[1].request.env['rack.blastwave.request_id']).to eq('2')
      expect(request_results[2].request.env['rack.blastwave.request_id']).to eq('3')
    end
  end
end
