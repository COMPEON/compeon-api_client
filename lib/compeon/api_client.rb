# frozen_string_literal: true

require 'compeon/api_client/version'

require 'faraday/middleware'

module Compeon
  class APIClient
    def initialize(version:, token: nil)
      @version = version
      @token_manager = case token
                       when String then StaticTokenManager.new(token)
                       when Object then token
                       end
    end

    private

    attr_reader :version

    def connection
      @connection ||= Faraday.new(url: ENV['COMPEON_API_URL']) do |connection|
        connection.adapter Faraday.default_adapter
        connection.headers['Content-Type'] = 'application/json'
        connection.response :json
      end

      @connection.headers['Authorization'] = "token #{token_manager.token}" if token_manager
      @connection
    end

    class StaticTokenManager
      def initialize(token)
        @token = token
      end

      attr_reader :token
    end
  end
end
