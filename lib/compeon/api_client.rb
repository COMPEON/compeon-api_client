# frozen_string_literal: true

require 'compeon/api_client/version'

require 'faraday_middleware'

require 'compeon/api_client/middlewares/jsonapi_request'
require 'compeon/api_client/middlewares/jsonapi_response'
require 'compeon/api_client/static_token_manager'

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

    def patch(*path_segments, **payload)
      connection.patch(path(path_segments), **payload)
    end

    def post(*path_segments, **payload)
      connection.post(path(path_segments), **payload)
    end

    def put(*path_segments, **payload)
      connection.put(path(path_segments), **payload)
    end

    private

    attr_reader :url, :version

    def path(path_segments)
      path_segments.map do |path_segment|
        actual_segment, query = path_segment.to_s.split('?')
        [actual_segment.tr('_', '-'), query].join('?')
      end.join('/')
    end

    def connection
      @connection ||= Faraday.new(url: url) do |connection|
        connection.headers['Content-Type'] = 'application/vnd.api+json'
        connection.request :jsonapi_request

        connection.response :jsonapi_response
        connection.response :raise_error
        connection.response :logger

        connection.adapter Faraday.default_adapter
      end

      @connection.headers['Authorization'] = "token #{@token_manager.token}" if @token_manager
      @connection
    end
  end
end
