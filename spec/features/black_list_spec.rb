# frozen_string_literal: true

RSpec.describe 'Rack::BlastWave::BlackList Middleware' do
  before do
    # NOTE: nameless filter
    Rack::BlastWave::BlackList.filter { |request| request.ip == '123.123.123.123' }

    # NOTE: named filter
    Rack::BlastWave::BlackList.filter('actions') { |request| request.get? || request.post? }
  end

  after { Rack::BlastWave::BlackList.clear! }

  describe 'defaults' do
    specify 'filter fetching' do
      middleware = Rack::BlastWave::BlackList.build

      filter_1_value = [true, false].sample
      filter_2_value = [true, false].sample
      filter_3_value = [true, false].sample

      filter_1 = proc { filter_1_value }
      filter_2 = proc { filter_2_value }
      filter_3 = proc { filter_3_value }

      middleware.filter('first_filter',  &filter_1)
      middleware.filter('second_filter', &filter_2)
      middleware.filter('third_filter',  &filter_3)

      expect(middleware.filter('first_filter').match?(double)).to  eq(filter_1_value)
      expect(middleware.filter('second_filter').match?(double)).to eq(filter_2_value)
      expect(middleware.filter('third_filter').match?(double)).to  eq(filter_3_value)
    end

    specify 'default settings' do
      middleware = Rack::BlastWave::BlackList.build

      middleware.config.settings.tap do |config|
        expect(config.check_all).to eq(false)
        expect(config.fail_response.status).to eq(403)
        expect(config.fail_response.body).to eq(["Forbidden\n"])
        expect(config.fail_response.headers).to eq('Content-Type' => 'text/plain')
      end
    end

    specify 'each middleware instance has own settings' do
      middleware_1 = Rack::BlastWave::BlackList.build.tap do |middleware|
        middleware.configure { |conf| conf.fail_response.status = 423 }
      end

      middleware_2 = Rack::BlastWave::BlackList.build.tap do |middleware|
        middleware.configure { |conf| conf.fail_response.status = 451 }
      end

      expect(middleware_1.new(double).options.fail_response.status).to eq(423)
      expect(middleware_2.new(double).options.fail_response.status).to eq(451)
    end
  end

  describe 'bad response configuration' do
    before { Rack::BlastWave::BlackList.configure { |conf| conf.check_all = false } }

    let(:app) { build_fake_rack_app(Rack::BlastWave::BlackList) }

    specify 'status code' do
      Rack::BlastWave::BlackList.configure { |c| c.fail_response.status = 423 }
      make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
      expect(last_response.status).to eq(423)

      Rack::BlastWave::BlackList.configure { |c| c.fail_response.status = 451 }
      make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
      expect(last_response.status).to eq(451)
    end

    specify 'body' do
      Rack::BlastWave::BlackList.configure { |c| c.fail_response.body = ['Locked!'] }
      make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
      expect(last_response.body).to eq('Locked!')

      Rack::BlastWave::BlackList.configure { |c| c.fail_response.body = ['Surprise!'] }
      make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
      expect(last_response.body).to eq('Surprise!')
    end

    specify 'headers' do
      Rack::BlastWave::BlackList.configure do |c|
        c.fail_response.headers = { 'X-Black-Lock' => 'used' }
      end

      make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
      expect(last_response.headers).to include('X-Black-Lock' => 'used')

      Rack::BlastWave::BlackList.configure do |c|
        c.fail_response.headers = {
          'X-Surprise-Black-Lock' => 'provided',
          'X-RSpec-BlackList'     => 'passed'
        }
      end

      make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
      expect(last_response.headers).to include(
        'X-Surprise-Black-Lock' => 'provided',
        'X-RSpec-BlackList'     => 'passed'
      )
    end
  end

  describe 'checking' do
    before { Rack::BlastWave::BlackList.configure { |conf| conf.fail_response.status = 403 } }

    let(:app) { build_fake_rack_app(Rack::BlastWave::BlackList) }

    context 'when at least one check should pass' do
      before { Rack::BlastWave::BlackList.configure { |conf| conf.check_all = false } }

      context 'all: passed' do
        specify 'request is blocked' do
          make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
          expect(last_response.status).to eq(403)
        end
      end

      context 'all: not passed' do
        specify 'request is allowed' do
          make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
          expect(last_response.status).to eq(200)
        end
      end

      context 'one: passed' do
        specify 'request is blocked' do
          # NOTE: only the ip filter is successfully passed
          make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
          expect(last_response.status).to eq(403)

          # NOTE: only the action type filter is successfully passed
          make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
          expect(last_response.status).to eq(403)
        end
      end
    end

    context 'when all checks should pass' do
      before { Rack::BlastWave::BlackList.configure { |conf| conf.check_all = true } }

      context 'all: passed' do
        specify 'request is blocked' do
          make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
          expect(last_response.status).to eq(403)
        end
      end

      context 'all: not passed' do
        specify 'request is allowed' do
          make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
          expect(last_response.status).to eq(200)
        end
      end

      context 'one: passed' do
        specify 'request is allowed' do
          # NOTE: only the ip filter is successfully passed
          make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
          expect(last_response.status).to eq(200)

          # NOTE: only the action type filter is successfully passed
          make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end