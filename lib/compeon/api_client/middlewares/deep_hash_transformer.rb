module Compeon
  class APIClient
    module Middlewares
      module DeepHashTransformer
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
  end
end
