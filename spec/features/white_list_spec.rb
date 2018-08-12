# frozen_string_literal: true

RSpec.describe 'Rack::BlastWave::WhiteList Middleware' do
  let(:app) { build_fake_rack_app(Rack::BlastWave::WhiteList) }
end
