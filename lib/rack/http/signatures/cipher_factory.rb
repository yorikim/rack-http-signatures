require 'rack/http/signatures/ciphers/rsa256'
require 'rack/http/signatures/ciphers/hs256'
require 'rack/http/signatures/errors/unknown_algorithm_error'

module Rack::Http::Signatures
  class CipherFactory
    class << self
      def create(algorithm)
        case algorithm
          when 'rsa-sha256'   then Ciphers::RSA256
          when 'hmac-sha256'  then Ciphers::HS256
          else raise Errors::UnknownAlgorithmError, 'Unknown algorithm'
        end
      end
    end
  end
end
