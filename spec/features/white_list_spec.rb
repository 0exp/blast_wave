# frozen_string_literal: true

describe 'Rack::BlastWave::WhiteList Middleware' do
  describe 'defaults' do
    specify 'filter fetching' do
      middleware = Rack::BlastWave::WhiteList.build

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
      middleware = Rack::BlastWave::WhiteList.build

      middleware.config.settings.tap do |config|
        expect(config.check_all).to eq(false)
        expect(config.fail_response.status).to eq(403)
        expect(config.fail_response.body).to eq(["Forbidden\n"])
        expect(config.fail_response.headers).to eq('Content-Type' => 'text/plain')
      end
    end

    specify 'each middleware instance has own settings' do
      middleware_1 = Rack::BlastWave::WhiteList.build.tap do |middleware|
        middleware.configure { |conf| conf.fail_response.status = 423 }
      end

      middleware_2 = Rack::BlastWave::WhiteList.build.tap do |middleware|
        middleware.configure { |conf| conf.fail_response.status = 451 }
      end

      expect(middleware_1.new(double).options.fail_response.status).to eq(423)
      expect(middleware_2.new(double).options.fail_response.status).to eq(451)
    end
  end

  describe 'filtering' do
    let(:app) { build_fake_rack_app(Rack::BlastWave::WhiteList) }

    describe 'common filters' do
      before do
        Rack::BlastWave::WhiteList.configure do |conf|
          conf.check_all = false
          conf.lock_requests = true
          conf.fail_response.status = 403
        end
      end

      describe 'ip addresses filter' do
        before { Rack::BlastWave::WhiteList.ip_addrs('127.0.0.1', '192.168.0.1/24') }

        after { Rack::BlastWave::WhiteList.clear! }

        specify 'allows requests only from an ip address filter' do
          # NOTE: filtered ip => allowed
          make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
          expect(last_response.status).to eq(200)

          # NOTE: filtered ip => allowed
          make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '192.168.0.1' })
          expect(last_response.status).to eq(200)

          # NOTE: unfiltered ip => blocked
          make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '192.168.1.1' })
          expect(last_response.status).to eq(403)
        end
      end
    end

    context 'with filters' do
      before do
        # NOTE: nameless filter
        Rack::BlastWave::WhiteList.filter { |request| request.ip == '123.123.123.123' }

        # NOTE: named filter
        Rack::BlastWave::WhiteList.filter('actions') { |request| request.get? || request.post? }
      end

      after { Rack::BlastWave::WhiteList.clear! }

      describe 'request interface' do
        before do
          Rack::BlastWave::WhiteList.configure { |conf| conf.check_all = false }

          # NOTE: add additional filter
          Rack::BlastWave::WhiteList.filter('root') { |request| request.path == '/' }
        end

        context 'with request locking' do
          before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = true } }

          specify 'rack env request data stores filter results' do
            # NOTE: non-locked request that was filtered by actions filter
            make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
            expect(last_request.env['rack.blastwave.white_list']).to match(
              locked: false, triggered_filters: contain_exactly('actions', 'root')
            )

            expect(last_request.white_list_info).to match(
              locked: false, triggered_filters: contain_exactly('actions', 'root')
            )
            expect(last_request.locked_by_white_list?).to eq(false)
            expect(last_request.triggered_white_list_filters).to contain_exactly('actions', 'root')

            # NOTE: non-locked request that wasnt filtered
            make_request(:options, '/any', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
            expect(last_request.env['rack.blastwave.white_list']).to match(
              locked: true, triggered_filters: []
            )
            expect(last_request.white_list_info).to match(
              locked: true, triggered_filters: []
            )
            expect(last_request.locked_by_white_list?).to eq(true)
            expect(last_request.triggered_white_list_filters).to eq([])
          end
        end

        context 'without request-locking' do
          before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = false } }

          specify 'stores all triggered filter names event when request locking is disabled' do
            make_request(:options, '/any')

            expect(last_request.white_list_info).to match(locked: false, triggered_filters: [])
          end
        end
      end

      describe 'bad response configuration' do
        before do
          Rack::BlastWave::WhiteList.configure do |conf|
            conf.check_all = false
            conf.lock_requests = true
          end
        end

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

      describe 'checking and locking' do
        before { Rack::BlastWave::WhiteList.configure { |conf| conf.fail_response.status = 403 } }

        let(:app) { build_fake_rack_app(Rack::BlastWave::WhiteList) }

        context 'when at least one check should pass' do
          before { Rack::BlastWave::WhiteList.configure { |conf| conf.check_all = false } }

          context 'all: passed' do
            context 'with request locking' do
              before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = true } }

              specify 'request is allowed' do
                make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
                expect(last_response.status).to eq(200)
              end
            end

            context 'without request locking' do
              before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = false } }

              specify 'request is allowed' do
                make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
                expect(last_response.status).to eq(200)
              end
            end
          end

          context 'all: not passed' do
            context 'with request locking' do
              before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = true } }

              specify 'request is blocked' do
                make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
                expect(last_response.status).to eq(403)
              end
            end

            context 'without request locking' do
              before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = false } }

              specify 'request is allowed' do
                make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
                expect(last_response.status).to eq(200)
              end
            end
          end

          context 'one: passed' do
            context 'with request locking' do
              before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = true } }

              specify 'request is allowed' do
                # NOTE: only the ip filter is successfully passed
                make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
                expect(last_response.status).to eq(200)

                # NOTE: only the action type filter is successfully passed
                make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
                expect(last_response.status).to eq(200)
              end
            end

            context 'without request locking' do
              before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = false } }

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

        context 'when all checks should pass' do
          before { Rack::BlastWave::WhiteList.configure { |conf| conf.check_all = true } }

          context 'all: passed' do
            context 'with request locking' do
              before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = true } }

              specify 'request is allowed' do
                make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
                expect(last_response.status).to eq(200)
              end
            end

            context 'without request locking' do
              before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = false } }

              specify 'request is allowed' do
                make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
                expect(last_response.status).to eq(200)
              end
            end
          end

          context 'all: not passed' do
            context 'with request locking' do
              before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = true } }

              specify 'request is blocked' do
                make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
                expect(last_response.status).to eq(403)
              end
            end

            context 'without request locking' do
              before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = false } }

              specify 'request is allowed' do
                make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
                expect(last_response.status).to eq(200)
              end
            end
          end

          context 'one: passed' do
            context 'with request locking' do
              before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = true } }

              specify 'request is blocked' do
                # NOTE: only the ip filter is successfully passed
                make_request(:head, '/', env_opts: { 'REMOTE_ADDR' => '123.123.123.123' })
                expect(last_response.status).to eq(403)

                # NOTE: only the action type filter is successfully passed
                make_request(:get, '/', env_opts: { 'REMOTE_ADDR' => '127.0.0.1' })
                expect(last_response.status).to eq(403)
              end
            end

            context 'without request locking' do
              before { Rack::BlastWave::WhiteList.configure { |conf| conf.lock_requests = false } }

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
    end
  end
end
