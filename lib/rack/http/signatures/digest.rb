module Rack
  module Http
    module Signatures
      class Digest
        VALID_ALGORITHMS = %w(sha-256).freeze

        attr_reader :body

        def initialize(algorithm, body)
          @algorithm = algorithm
          @body = body
        end

        def valid_algorithm?
          VALID_ALGORITHMS.include?(@algorithm.downcase)
        end

        def self.from_string(string)
          algorithm, body64 = string.split('=', 2)
          Digest.new(algorithm, Base64.decode64(body64))
        end
      end
    end
  end
end
