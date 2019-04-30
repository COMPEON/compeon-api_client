# frozen_string_literal: true

require_relative 'deep_hash_transformer'

require 'json'

module Compeon
  class APIClient
    module Middlewares
      class JSONAPIRequestMiddleware < Faraday::Middleware
        include DeepHashTransformer

        Faraday::Request.register_middleware jsonapi_request: self

        def call(env)
          if env.body
            body = deep_transform_keys(env.body) do |key|
              key.to_s.tr('_', '-')
            end

            env.body = JSON.pretty_generate(body)
          end
          @app.call(env)
        end
      end
    end
  end
end
