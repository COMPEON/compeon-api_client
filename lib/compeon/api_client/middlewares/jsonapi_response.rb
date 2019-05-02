# frozen_string_literal: true

require_relative 'deep_hash_transformer'

require 'json'

module Compeon
  class APIClient
    module Middlewares
      class JSONAPIResponseMiddleware < Faraday::Response::Middleware
        include DeepHashTransformer

        Faraday::Response.register_middleware jsonapi_response: self

        def parse(json_body)
          hash_body = JSON.load(json_body)

          deep_transform_keys(hash_body) do |key|
            key.tr('-', '_').to_sym
          end
        end
      end
    end
  end
end
