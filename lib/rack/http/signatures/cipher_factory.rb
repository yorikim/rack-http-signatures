require 'rack/http/signatures/ciphers/rsa256'
require 'rack/http/signatures/errors/unknown_algorithm_error'

module Rack::Http::Signatures
  class CipherFactory
    def self.create(algorithm)
      case algorithm
        when 'rsa-sha256' then Ciphers::RSA256
        else raise Errors::UnknownAlgorithmError, 'Unknown algorithm'
      end
    end
  end
end
