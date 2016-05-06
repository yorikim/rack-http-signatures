module Rack::Http::Signatures
  class Digest
    VALID_ALGORITHMS = %w(SHA-256)

    attr_reader :body

    def initialize(algorithm, body)
      @algorithm = algorithm
      @body = body
    end

    def valid_algorithm?
      VALID_ALGORITHMS.include?(@algorithm)
    end

    def self.from_string(string)
      algorithm, body64 = string.split('=', 2)
      Digest.new(algorithm, Base64.decode64(body64))
    end
  end
end
