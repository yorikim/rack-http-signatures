require 'rack/http/signatures/ciphers/rsa256'
require 'rack/http/signatures/ciphers/hs256'

module Rack
  module Http
    module Signatures
      class CipherFactory
        UnknownAlgorithmError = Class.new(ArgumentError)
        VALID_ALGORITHMS = %w(rsa-sha256 hmac-sha256).freeze

        class << self
          def create(algorithm)
            case algorithm
            when 'rsa-sha256' then
              Ciphers::RSA256
            when 'hmac-sha256' then
              Ciphers::HS256
            else
              raise UnknownAlgorithmError, 'Unknown algorithm'
            end
          end
        end
      end
    end
  end
end
