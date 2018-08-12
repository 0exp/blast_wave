# frozen_string_literal: true

module SpecSupport
  module FakeApp
    class MinimalRackApp
      def call(env)
        Rack::Response.new(env).finish
      end
    end

    def build_fake_rack_app(*middlewares)
      Rack::Builder.new do
        middlewares.map(&method(:use))
        run MinimalRackApp.new
      end
    end
  end
end
