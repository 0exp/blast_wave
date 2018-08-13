# frozen_string_literal: true

RSpec.describe 'Rack::BlastWave::WhiteList Middleware' do
  before do
    Rack::BlastWave::WhiteList.filter { |request| request.ip == '123.123.123.123' }
    Rack::BlastWave::WhiteList.filter { |request| request.get? }
  end

  after { Rack::BlastWave::WhiteList.clear! }

  describe 'bad response configuration' do
    before { Rack::BlastWave::WhiteList.configure { |conf| conf.check_all = false } }

    let(:app) { build_fake_rack_app(Rack::BlastWave::WhiteList) }

    specify 'status code' do
      Rack::BlastWave::WhiteList.configure { |c| c.fail_response.status = 423 }
      make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
      expect(last_response.status).to eq(423)

      Rack::BlastWave::WhiteList.configure { |c| c.fail_response.status = 451 }
      make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
      expect(last_response.status).to eq(451)
    end

    specify 'body' do
      Rack::BlastWave::WhiteList.configure { |c| c.fail_response.body = ['Locked!'] }
      make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
      expect(last_response.body).to eq('Locked!')

      Rack::BlastWave::WhiteList.configure { |c| c.fail_response.body = ['Surprise!'] }
      make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
      expect(last_response.body).to eq('Surprise!')
    end

    specify 'headers' do
      Rack::BlastWave::WhiteList.configure do |c|
        c.fail_response.headers = { 'X-White-Lock' => 'used' }
      end

      make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
      expect(last_response.headers).to include('X-White-Lock' => 'used')

      Rack::BlastWave::WhiteList.configure do |c|
        c.fail_response.headers = {
          'X-Surprise-White-Lock' => 'provided',
          'X-RSpec-WhiteList'     => 'passed'
        }
      end

      make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
      expect(last_response.headers).to include(
        'X-Surprise-White-Lock' => 'provided',
        'X-RSpec-WhiteList'     => 'passed'
      )
    end
  end

  describe 'checking' do
    before { Rack::BlastWave::WhiteList.configure { |conf| conf.fail_response.status = 403 } }

    let(:app) { build_fake_rack_app(Rack::BlastWave::WhiteList) }

    context 'when at least one check should pass' do
      before { Rack::BlastWave::WhiteList.configure { |conf| conf.check_all = false } }

      context 'all: passed' do
        specify 'request is allowed' do
          make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
          expect(last_response.status).to eq(200)
        end
      end

      context 'all: not passed' do
        specify 'request is blocked' do
          make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
          expect(last_response.status).to eq(403)
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

    context 'when all checks should pass' do
      before { Rack::BlastWave::WhiteList.configure { |conf| conf.check_all = true } }

      context 'all: passed' do
        specify 'request is allowed' do
          make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
          expect(last_response.status).to eq(200)
        end
      end

      context 'all: not passed' do
        specify 'request is blocked' do
          make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
          expect(last_response.status).to eq(403)
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
  end
end
