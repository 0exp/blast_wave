# frozen_string_literal: true

RSpec.describe 'Rack::BlastWave::BlackList Middleware' do
  let!(:app) { build_fake_rack_app(Rack::BlastWave::BlackList) }
end
