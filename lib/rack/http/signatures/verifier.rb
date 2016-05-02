require 'rack/http/signatures/cipher_factory'

module Rack::Http::Signatures
  module Verifier
    def self.verify(algorithm, key, base64_signature, data)
      CipherFactory.create(algorithm).verify(key, Base64.decode64(base64_signature), data)
    end
  end
end
