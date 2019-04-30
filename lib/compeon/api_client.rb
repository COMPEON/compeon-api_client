# frozen_string_literal: true

require 'compeon/api_client/version'

require 'faraday_middleware'

module Compeon
  class APIClient
    def initialize(version:, token: nil, url: ENV['COMPEON_API_URL'])
      @url = "#{url}/v#{version}"
      @version = version
      @token_manager = case token
                       when String then StaticTokenManager.new(token)
                       when Object then token
                       end
    end

    def get(*path_segments)
      connection.get(path(path_segments))
    end

    def post(*path_segments, **payload)
      connection.post(path(path_segments), **payload)
    end

    def put(*path_segments, **payload)
      connection.put(path(path_segments), **payload)
    end

    private

    attr_reader :url, :version

    def path(*path_segments)
      [*path_segments].join('/')
    end

    def connection
      @connection ||= Faraday.new(url: url) do |connection|
        connection.headers['Content-Type'] = 'application/json'
        connection.request :jsonapi_request

        connection.response :jsonapi_response
        connection.response :raise_error
        connection.response :logger

        connection.adapter Faraday.default_adapter
      end

      @connection.headers['Authorization'] = "token #{@token_manager.token}" if @token_manager
      @connection
    end

    class StaticTokenManager
      def initialize(token)
        @token = token
      end

      attr_reader :token
    end

    module DeepHashTransformer
      class << self
        def deep_transform_keys(object, &block)
          case object
          when Hash
            object.each_with_object({}) do |(key, value), result|
              result[yield(key)] = deep_transform_keys(value, &block)
            end
          when Array
            object.map { |e| deep_transform_keys(e, &block) }
          else
            object
          end
        end
      end
    end

    class JSONAPIRequestMiddleware < Faraday::Response::Middleware
      Faraday::Request.register_middleware jsonapi_request: self

      def call(env)
        if env.body
          body = DeepHashTransformer.deep_transform_keys(env.body) do |key|
            key.to_s.tr('_', '-')
          end

          env.body = JSON.pretty_generate(body)
        end
        @app.call(env)
      end
    end

    class JSONAPIResponseMiddleware < Faraday::Response::Middleware
      Faraday::Response.register_middleware jsonapi_response: self

      def parse(json_body)
        hash_body = JSON.load(json_body)

        DeepHashTransformer.deep_transform_keys(hash_body) do |key|
          key.tr('-', '_').to_sym
        end
      end
    end
  end
end
