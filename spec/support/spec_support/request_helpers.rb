# frozen_string_literal: true

module SpecSupport::RequestHelpers
  class RequestSeriesResult
    attr_reader :current_time
    attr_reader :request
    attr_reader :response

    def initialize(current_time, request, response)
      @current_time = current_time
      @request      = request
      @response     = response
    end
  end

  def make_request(method = :get, path = '/', query_opts: {}, env_opts: {})
    send(method, path, query_opts, env_opts)
  end

  def make_request_series(count, method = :get, path = '/', query_opts: {}, env_opts: {})
    [].tap do |request_results|
      count.times do |current_time|
        make_request(method, path, query_opts: query_opts, env_opts: env_opts)

        request_results << RequestSeriesResult.new(
          current_time,
          last_request,
          last_response
        )
      end
    end
  end
end
