# frozen_string_literal: true

module Compeon
  class APIClient
    class StaticTokenManager
      def initialize(token)
        @token = token
      end

      attr_reader :token
    end
  end
end
